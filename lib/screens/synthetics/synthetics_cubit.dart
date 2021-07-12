import 'dart:async';

import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/transaction.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/models/synthetics/stock_address.dart';
import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/service/sync/heco_stock_service.dart';
import 'package:deus_mobile/service/sync/matic_stock_service.dart';
import 'package:deus_mobile/service/sync/xdai_stock_service.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';
import 'package:intl/intl.dart';

abstract class SyntheticsCubit extends Cubit<SyntheticsState> {
  SyntheticsCubit(SyntheticsChain chain) : super(SyntheticsInitialState(chain));

  init({SyntheticsState? syntheticsState}) async {
    if (syntheticsState != null) {
      addListenerToFromField(syntheticsState);
      emit(syntheticsState);
    } else {
      emit(SyntheticsLoadingState(state));
      bool res1 = await state.syncData.getData();
      state.prices = await state.syncData.getPrices();
      if (res1 && state.prices.length > 0) {
        state.marketTimerClosed = checkMarketStatus();
        (state.fromToken as CryptoCurrency).balance =
            await getTokenBalance(state.fromToken);
        state.database = await AppDatabase.getInstance();

        state.timer =
        new Timer.periodic(Duration(seconds: 14), (Timer t) => getPrices());
        addListenerToFromField(state);
        emit(SyntheticsSelectAssetState(state));
      } else {
        emit(SyntheticsErrorState(state));
      }
    }
  }

  Future<String> getTokenAddress(Token token) async {
    String tokenAddress = "";
    if (token.getTokenName() == "busd") {
      tokenAddress =
          await state.service.ethService.getTokenAddrHex("busd", "token");
    } else if (token.getTokenName() == "xdai") {
      tokenAddress = XDaiStockService.xdaiTokenAddress;
    } else if (token.getTokenName() == "dai") {
      tokenAddress =
          await state.service.ethService.getTokenAddrHex("dai", "token");
    } else if (token.getTokenName() == "husd") {
      tokenAddress = HecoStockService.husd;
    } else if (token.getTokenName() == "usdc") {
      tokenAddress = MaticStockService.usdc;
    } else {
      StockAddress? stockAddress = state.syncData.getStockAddress(token);
      if (state.mode == Mode.LONG) {
        tokenAddress = stockAddress!.long;
      } else if (state.mode == Mode.SHORT) {
        tokenAddress = stockAddress!.short;
      }
    }
    return tokenAddress;
  }

  DateTime marketStatusChanged() {
    DateTime now = getNYC();
    List closedDays = ['Sat', 'Sun'];
    var f = DateFormat('EEE,HH,mm,ss');
    var date = f.format(now);
    List arr = date.split(',');
    if (!closedDays.contains(arr[0])) {
      if ((int.parse(arr[1]) == 6 &&
              int.parse(arr[2]) > 30 &&
              int.parse(arr[1]) < 20) ||
          (int.parse(arr[1]) > 6 && int.parse(arr[1]) < 20)) {
        return DateTime.utc(now.year, now.month, now.day, 20, 0);
      }
    }

    //when market opens
    if (arr[0] == "Fri") {
      if (int.parse(arr[1]) < 6 ||
          (int.parse(arr[1]) == 6 && int.parse(arr[2]) < 30)) {
        return DateTime.utc(now.year, now.month, now.day, 6, 30);
      } else {
        return DateTime.utc(now.year, now.month, now.day, 6, 30)
            .add(Duration(days: 3));
      }
    } else if (arr[0] == "Sat") {
      return DateTime.utc(now.year, now.month, now.day, 6, 30)
          .add(Duration(days: 2));
    } else if (arr[0] == "Sun") {
      return DateTime.utc(now.year, now.month, now.day, 6, 30)
          .add(Duration(days: 1));
    } else {
      if (int.parse(arr[1]) < 6 ||
          (int.parse(arr[1]) == 6 && int.parse(arr[2]) < 30)) {
        return DateTime.utc(now.year, now.month, now.day, 6, 30);
      } else {
        return DateTime.utc(now.year, now.month, now.day, 6, 30)
            .add(Duration(days: 1));
      }
    }
  }

  Future getTokenBalance(Token token) async {
    String tokenAddress = await getTokenAddress(token);
    return await state.service.getTokenBalance(tokenAddress);
  }

  Future getAllowances() async {
    emit(SyntheticsAssetSelectedState(state,
        approved: false, isInProgress: true));
    String? tokenAddress = await getTokenAddress(state.fromToken);
    if (isBuy()) {
      (state.fromToken as CryptoCurrency).allowances =
          await state.service.getAllowances(tokenAddress);
      if ((state.fromToken as CryptoCurrency).getAllowances() > BigInt.zero)
        emit(SyntheticsAssetSelectedState(state,
            approved: true, isInProgress: false));
      else
        emit(SyntheticsAssetSelectedState(state,
            approved: false, isInProgress: false));
    } else {
      if (state.mode == Mode.LONG) {
        (state.fromToken as Stock).longAllowances =
            await state.service.getAllowances(tokenAddress);
        if ((state.fromToken as Stock).getAllowances()! > BigInt.zero)
          emit(SyntheticsAssetSelectedState(state,
              approved: true, isInProgress: false));
        else
          emit(SyntheticsAssetSelectedState(state,
              approved: false, isInProgress: false));
      } else if (state.mode == Mode.SHORT) {
        (state.fromToken as Stock).shortAllowances =
            await state.service.getAllowances(tokenAddress);
        if ((state.fromToken as Stock).getAllowances()! > BigInt.zero)
          emit(SyntheticsAssetSelectedState(state,
              approved: true, isInProgress: false));
        else
          emit(SyntheticsAssetSelectedState(state,
              approved: false, isInProgress: false));
      }
    }
  }

  String getPriceRatio() {
    double a = double.tryParse(state.fromFieldController.text) ?? 0;
    double b = state.toValue;
    if (a != 0 && b != 0) {
      if (state.isPriceRatioForward)
        return EthereumService.formatDouble((a / b).toString(), 5);
      return EthereumService.formatDouble((b / a).toString(), 5);
    }
    return "0.0";
  }

  fromTokenChanged(Token selectedToken) async {
    state.toToken = state.mainToken;
    state.fromToken = selectedToken;
    (state.fromToken as Stock).mode = Mode.LONG;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;

    if (checkMarketClosed(selectedToken, Mode.LONG)) {
      state.marketClosed = true;
      emit(SyntheticsLoadingState(state));
      emit(SyntheticsAssetSelectedState(state,
          fromToken: selectedToken, mode: Mode.LONG));
    } else {
      state.marketClosed = false;
      emit(SyntheticsAssetSelectedState(state,
          fromToken: selectedToken, mode: Mode.LONG, isInProgress: true));

      await getAllowances();
      (selectedToken as Stock).longBalance =
          await getTokenBalance(selectedToken);
      emit(SyntheticsLoadingState(state));
      emit(SyntheticsAssetSelectedState(state,
          fromToken: selectedToken, isInProgress: false));
    }
  }

  toTokenChanged(Token selectedToken) async {
    state.fromToken = state.mainToken;
    state.toToken = selectedToken;
    (state.toToken as Stock).mode = Mode.LONG;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;

    if (checkMarketClosed(selectedToken, Mode.LONG)) {
      state.marketClosed = true;
      emit(SyntheticsLoadingState(state));
      emit(SyntheticsAssetSelectedState(state,
          toToken: selectedToken, mode: Mode.LONG));
    } else {
      state.marketClosed = false;
      emit(SyntheticsAssetSelectedState(state,
          toToken: selectedToken, mode: Mode.LONG, isInProgress: true));

      await getAllowances();
      (selectedToken as Stock).longBalance =
          await getTokenBalance(selectedToken);
      emit(SyntheticsLoadingState(state));
      emit(SyntheticsAssetSelectedState(state,
          toToken: selectedToken, isInProgress: false));
    }
  }

  addListenerToFromField(SyntheticsState s) {
    s.fromFieldController = new TextEditingController();
    s.toFieldController = new TextEditingController();
    s.toValue = 0;
    s.inputController = new StreamController();
    s.fromFieldController.addListener(listenInput);
    s.inputController.stream
        .debounce(Duration(milliseconds: 500))
        .listen((s) {
      if (!(state is SyntheticsSelectAssetState)) {
        emit(SyntheticsAssetSelectedState(state, isInProgress: true));
        if (double.tryParse(s)! > 0) {
          double value = computeToPrice(s);
          state.toValue = value;
          state.toFieldController.text =
              EthereumService.formatDouble(value.toStringAsFixed(18));
        } else {
          state.toValue = 0;
          state.toFieldController.text = "0.0";
        }
        emit(SyntheticsAssetSelectedState(state, isInProgress: false));
      }
    });
  }

  int getDecimalNumbers(String token) {
    if (token == "husd")
      return 8;
    else
      return 18;
  }

  listenInput() async {
    if (!(state is SyntheticsSelectAssetState)) {
      String input = state.fromFieldController.text;
      if (input.isEmpty) {
        input = "0.0";
      }

      if (isBuy()) {
        if ((state.fromToken as CryptoCurrency).getAllowances() >=
            EthereumService.getWei(input)) {
          state.inputController.add(input);
          emit(SyntheticsAssetSelectedState(state, approved: true));
        } else {
          state.inputController.add(input);
          emit(SyntheticsAssetSelectedState(state, approved: false));
        }
      } else {
        if ((state.fromToken as Stock).getAllowances()! >=
            EthereumService.getWei(input, state.mainToken.getTokenName())) {
          state.inputController.add(input);
          emit(SyntheticsAssetSelectedState(state, approved: true));
        } else {
          state.inputController.add(input);
          emit(SyntheticsAssetSelectedState(state, approved: false));
        }
      }
    }
  }

  reverseSync() {
    Token a = state.fromToken;
    state.fromToken = state.toToken!;
    state.toToken = a;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;
    getAllowances();
  }

  reversePriceRatio() {
    if (state is SyntheticsAssetSelectedState) {
      emit(SyntheticsAssetSelectedState(state,
          isPriceRatioForward: !state.isPriceRatioForward));
    }
  }

  Future<void> setMode(Mode mode) async {
    if (!state.isInProgress && state.toToken != null) {
      if (mode != state.mode) {
        state.toFieldController.text = "";
        // state.fromFieldController.text = "";
        state.toValue = 0;
        state.approved = false;
      }
      if (isBuy()) {
        (state.toToken as Stock).mode = mode;
      } else {
        (state.fromToken as Stock).mode = mode;
      }
      if (checkMarketClosed(isBuy() ? state.toToken! : state.fromToken, mode)) {
        state.marketClosed = true;
        emit(SyntheticsAssetSelectedState(state, mode: mode));
      } else {
        state.marketClosed = false;
        emit(SyntheticsAssetSelectedState(state, mode: mode));
        await getAllowances();
        listenInput();
      }
    }
  }

  void closeToast() {
    if (state is SyntheticsTransactionPendingState)
      emit(SyntheticsTransactionPendingState(state, showingToast: false));
    else if (state is SyntheticsTransactionFinishedState)
      emit(SyntheticsTransactionFinishedState(state, showingToast: false));
  }

  int getChainId() {
    switch (state.syntheticsChain) {
      case SyntheticsChain.ETH:
        return 1;
      case SyntheticsChain.XDAI:
        return 100;
      case SyntheticsChain.MATIC:
        return 137;
      case SyntheticsChain.HECO:
        return 128;
      case SyntheticsChain.BSC:
        return 56;
    }
  }

  Future approve(Gas? gas) async {
    if (!state.isInProgress) {
      if (gas != null) {
        DbTransaction? transaction;
        try {
          var res = await state.service
              .approve(await getTokenAddress(state.fromToken), gas);

          transaction = new DbTransaction(
              chainId: getChainId(),
              hash: res,
              type: TransactionType.APPROVE.index,
              title: state.fromToken is CryptoCurrency
                  ? state.fromToken.symbol
                  : state.mode == Mode.SHORT
                      ? (state.fromToken as Stock).shortSymbol
                      : (state.fromToken as Stock).longSymbol);
          List<int> ids = await state.database!.transactionDao
              .insertDbTransaction([transaction]);
          transaction.id = ids[0];

          emit(SyntheticsTransactionPendingState(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.fromToken.name}",
                  Status.PENDING,
                  "Transaction Pending",
                  res)));
          Stream<TransactionReceipt> result =
              state.service.ethService.pollTransactionReceipt(res);
          result.listen((event) async {
            state.approved = event.status!;
            if (event.status!) {
              state.approved = true;
              emit(SyntheticsTransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Approve ${state.fromToken.name}",
                      Status.SUCCESSFUL,
                      "Transaction Successful",
                      res)));
            } else {
              emit(SyntheticsTransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Approve ${state.fromToken.name}",
                      Status.FAILED,
                      "Transaction Failed",
                      res)));
            }
            transaction!.isSuccess = event.status;
            await state.database!.transactionDao
                .updateDbTransactions([transaction]);
          });
        } on Exception catch (value) {
          state.approved = false;

          if (transaction != null) {
            transaction.isSuccess = false;
            state.database!.transactionDao.updateDbTransactions([transaction]);
          } else {
            transaction = new DbTransaction(
                chainId: getChainId(),
                hash: "",
                type: TransactionType.APPROVE.index,
                title: state.fromToken is CryptoCurrency
                    ? state.fromToken.symbol
                    : state.mode == Mode.SHORT
                        ? (state.fromToken as Stock).shortSymbol
                        : (state.fromToken as Stock).longSymbol);
            List<int> ids = await state.database!.transactionDao
                .insertDbTransaction([transaction]);
            transaction.id = ids[0];
          }

          emit(SyntheticsTransactionFinishedState(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.fromToken.name}",
                  Status.FAILED,
                  "Transaction Failed")));
        }
      }
    } else {
      state.approved = false;
      emit(SyntheticsTransactionFinishedState(state,
          transactionStatus: TransactionStatus(
              "Approve ${state.fromToken.name}",
              Status.FAILED,
              "Transaction Failed")));
    }
  }

  Future sell(Gas? gas) async {
    if (state.approved && !state.isInProgress) {
      if (gas != null) {
        emit(SyntheticsTransactionPendingState(state,
            transactionStatus: TransactionStatus(
                "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                Status.PENDING,
                "Transaction Pending")));
        String tokenAddress = await getTokenAddress(state.fromToken);

        List<ContractInputData> oracles = await state.syncData
            .getContractInputData(tokenAddress,
                await state.service.ethService.ethClient.getBlockNumber());
        if (oracles.length >= 2) {
          DbTransaction? transaction;
          try {
            //sort oracles on price and then on oracle number
            List arr = [];
            oracles.asMap().forEach((index, element) {
              arr.add([index, element.getPrice()]);
            });
            arr.sort((a, b) => a[1].compareTo(b[1]));

            List<ContractInputData> inputOracles;
            if (arr[0][0] < arr[1][0]) {
              inputOracles = [oracles[arr[0][0]], oracles[arr[1][0]]];
            } else {
              inputOracles = [oracles[arr[1][0]], oracles[arr[0][0]]];
            }

            var res = await state.service.sell(tokenAddress,
                state.fromFieldController.text, inputOracles, gas);

            transaction = new DbTransaction(
                chainId: getChainId(),
                hash: res,
                type: TransactionType.SELL.index,
                title: state.fromToken is CryptoCurrency
                    ? state.fromToken.symbol
                    : state.mode == Mode.SHORT
                        ? (state.fromToken as Stock).shortSymbol
                        : (state.fromToken as Stock).longSymbol);
            List<int> ids = await state.database!.transactionDao
                .insertDbTransaction([transaction]);
            transaction.id = ids[0];

            emit(SyntheticsTransactionPendingState(state,
                transactionStatus: TransactionStatus(
                    "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                    Status.PENDING,
                    "Transaction Pending",
                    res)));

            Stream<TransactionReceipt> result =
                state.service.ethService.pollTransactionReceipt(res);
            result.listen((event) async {
              transaction!.isSuccess = event.status;
              int ids = await state.database!.transactionDao
                  .updateDbTransactions([transaction]);

              if (event.status!) {
                String fromBalance = await getTokenBalance(state.fromToken);
                String toBalance = await getTokenBalance(state.toToken!);
                if (state.mode == Mode.LONG)
                  (state.fromToken as Stock).longBalance = fromBalance;
                else
                  (state.fromToken as Stock).shortBalance = fromBalance;

                (state.toToken as CryptoCurrency).balance = toBalance;

                emit(SyntheticsTransactionFinishedState(state,
                    transactionStatus: TransactionStatus(
                        "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                        Status.SUCCESSFUL,
                        "Transaction Successful",
                        res)));
              } else {
                emit(SyntheticsTransactionFinishedState(state,
                    transactionStatus: TransactionStatus(
                        "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                        Status.FAILED,
                        "Transaction Failed",
                        res)));
              }
            });
          } on Exception catch (e) {
            if (transaction != null) {
              transaction.isSuccess = false;
              int ids = await state.database!.transactionDao
                  .updateDbTransactions([transaction]);
            } else {
              transaction = new DbTransaction(
                  chainId: getChainId(),
                  hash: "",
                  type: TransactionType.SELL.index,
                  title: state.fromToken is CryptoCurrency
                      ? state.fromToken.symbol
                      : state.mode == Mode.SHORT
                          ? (state.fromToken as Stock).shortSymbol
                          : (state.fromToken as Stock).longSymbol);
              List<int> ids = await state.database!.transactionDao
                  .insertDbTransaction([transaction]);
              transaction.id = ids[0];
            }

            emit(SyntheticsTransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    e.toString(), Status.FAILED, "Transaction Failed")));
          }
        } else {
          emit(SyntheticsTransactionFinishedState(state,
              transactionStatus: TransactionStatus("oracles not available",
                  Status.FAILED, "Transaction Failed")));
        }
      } else {
        emit(SyntheticsTransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                Status.FAILED,
                "Rejected")));
      }
    }
  }

  Future buy(Gas? gas) async {
    if (state.approved && !state.isInProgress) {
      if (gas != null) {
        emit(SyntheticsTransactionPendingState(state,
            transactionStatus: TransactionStatus(
                "Buy ${state.toFieldController.text} ${state.toToken!.getTokenName()}",
                Status.PENDING,
                "Transaction Pending")));
        String tokenAddress = await getTokenAddress(state.toToken!);
        List<ContractInputData> oracles = await state.syncData
            .getContractInputData(tokenAddress,
                await state.service.ethService.ethClient.getBlockNumber());
        if (oracles.length >= 2) {
          DbTransaction? transaction;
          try {
            //sort oracles on price and then on oracle number
            List arr = [];
            oracles.asMap().forEach((index, element) {
              arr.add([index, element.getPrice()]);
            });
            arr.sort((a, b) => b[1].compareTo(a[1]));

            List<ContractInputData> inputOracles;
            if (arr[0][0] < arr[1][0]) {
              inputOracles = [oracles[arr[0][0]], oracles[arr[1][0]]];
            } else {
              inputOracles = [oracles[arr[1][0]], oracles[arr[0][0]]];
            }
            String maxPrice = arr[0][1].toString();
            var res;

            res = await state.service.buy(tokenAddress,
                state.toValue.toStringAsFixed(18), inputOracles, gas,
                maxPrice: maxPrice);

            transaction = new DbTransaction(
                chainId: getChainId(),
                hash: res,
                type: TransactionType.BUY.index,
                title: state.toToken is CryptoCurrency
                    ? state.toToken!.symbol
                    : state.mode == Mode.SHORT
                        ? (state.toToken as Stock).shortSymbol
                        : (state.toToken as Stock).longSymbol);
            List<int> ids = await state.database!.transactionDao
                .insertDbTransaction([transaction]);
            transaction.id = ids[0];

            emit(SyntheticsTransactionPendingState(state,
                transactionStatus: TransactionStatus(
                    "Buy ${state.toFieldController.text} ${state.toToken!.getTokenName()}",
                    Status.PENDING,
                    "Transaction Pending",
                    res)));
            Stream<TransactionReceipt> result =
                state.service.ethService.pollTransactionReceipt(res);
            result.listen((event) async {
              transaction!.isSuccess = event.status!;
              int ids = await state.database!.transactionDao
                  .updateDbTransactions([transaction]);
              if (event.status!) {
                String fromBalance = await getTokenBalance(state.fromToken);
                String toBalance = await getTokenBalance(state.toToken!);
                if (state.mode == Mode.LONG)
                  (state.toToken as Stock).longBalance = toBalance;
                else
                  (state.toToken as Stock).shortBalance = toBalance;

                (state.fromToken as CryptoCurrency).balance = fromBalance;

                //TODO add to wallet
                switch (state.syntheticsChain) {
                  case SyntheticsChain.ETH:
                    WalletAsset? ws = await state.database!.walletAssetDao
                        .getWalletAsset(1, tokenAddress);
                    if (ws == null) {
                      StockAddress? stockAddress = state.syncData
                          .getStockAddressFromAddress(tokenAddress);
                      Stock? stock =
                          state.syncData.getStockFromAddress(stockAddress!);
                      WalletAsset walletAsset = new WalletAsset(
                          chainId: 1,
                          tokenAddress: tokenAddress,
                          tokenSymbol: stock!.symbol,
                          logoPath: stock.logoPath,
                          valueWhenInserted: 0);
                      await state.database!.walletAssetDao
                          .insertWalletAsset([walletAsset]);
                    }

                    break;
                  case SyntheticsChain.XDAI:
                    WalletAsset? ws = await state.database!.walletAssetDao
                        .getWalletAsset(100, tokenAddress);
                    if (ws == null) {
                      StockAddress? stockAddress = state.syncData
                          .getStockAddressFromAddress(tokenAddress);
                      Stock? stock =
                          state.syncData.getStockFromAddress(stockAddress!);
                      WalletAsset walletAsset = new WalletAsset(
                          chainId: 100,
                          tokenAddress: tokenAddress,
                          tokenSymbol: stock!.symbol,
                          logoPath: stock.logoPath,
                          valueWhenInserted: 0);
                      await state.database!.walletAssetDao
                          .insertWalletAsset([walletAsset]);
                    }
                    break;
                  case SyntheticsChain.MATIC:
                    // TODO: Handle this case.
                    break;
                  case SyntheticsChain.HECO:
                    WalletAsset? ws = await state.database!.walletAssetDao
                        .getWalletAsset(128, tokenAddress);
                    if (ws == null) {
                      StockAddress? stockAddress = state.syncData
                          .getStockAddressFromAddress(tokenAddress);
                      Stock? stock =
                          state.syncData.getStockFromAddress(stockAddress!);
                      WalletAsset walletAsset = new WalletAsset(
                          chainId: 128,
                          tokenAddress: tokenAddress,
                          tokenSymbol: stock!.symbol,
                          logoPath: stock.logoPath,
                          valueWhenInserted: 0);
                      await state.database!.walletAssetDao
                          .insertWalletAsset([walletAsset]);
                    }
                    break;
                  case SyntheticsChain.BSC:
                    WalletAsset? ws = await state.database!.walletAssetDao
                        .getWalletAsset(56, tokenAddress);
                    if (ws == null) {
                      StockAddress? stockAddress = state.syncData
                          .getStockAddressFromAddress(tokenAddress);
                      Stock? stock =
                          state.syncData.getStockFromAddress(stockAddress!);
                      WalletAsset walletAsset = new WalletAsset(
                          chainId: 56,
                          tokenAddress: tokenAddress,
                          tokenSymbol: stock!.symbol,
                          logoPath: stock.logoPath,
                          valueWhenInserted: 0);
                      await state.database!.walletAssetDao
                          .insertWalletAsset([walletAsset]);
                    }
                    break;
                }

                emit(SyntheticsTransactionFinishedState(state,
                    transactionStatus: TransactionStatus(
                        "Buy ${state.toFieldController.text} ${state.toToken!.getTokenName()}",
                        Status.SUCCESSFUL,
                        "Transaction Successful",
                        res)));
              } else {
                emit(SyntheticsTransactionFinishedState(state,
                    transactionStatus: TransactionStatus(
                        "Buy ${state.toFieldController.text} ${state.toToken!.getTokenName()}",
                        Status.FAILED,
                        "Transaction Failed",
                        res)));
              }
            });
          } on Exception catch (error) {
            if (transaction != null) {
              transaction.isSuccess = false;
              int ids = await state.database!.transactionDao
                  .updateDbTransactions([transaction]);
            } else {
              transaction = new DbTransaction(
                  chainId: getChainId(),
                  hash: "",
                  type: TransactionType.BUY.index,
                  title: state.toToken is CryptoCurrency
                      ? state.toToken!.symbol
                      : state.mode == Mode.SHORT
                          ? (state.toToken as Stock).shortSymbol
                          : (state.toToken as Stock).longSymbol);
              List<int> ids = await state.database!.transactionDao
                  .insertDbTransaction([transaction]);
              transaction.id = ids[0];
            }

            emit(SyntheticsTransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    error.toString(), Status.FAILED, "Transaction Failed")));
          }
        } else {
          emit(SyntheticsTransactionFinishedState(state,
              transactionStatus: TransactionStatus("oracles not available",
                  Status.FAILED, "Transaction Failed")));
        }
      } else {
        emit(SyntheticsTransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Buy ${state.toFieldController.text} ${state.toToken!.getTokenName()}",
                Status.FAILED,
                "Rejected")));
      }
    }
  }

  void dispose() {
    state.timer?.cancel();
  }

  void getPrices() async {
    state.prices = await state.syncData.getPrices();
  }

  bool checkMarketClosed(Token selectedToken, Mode mode) {
    if (state.prices.length > 0) {
      if (mode == Mode.LONG) {
        if (state.prices[selectedToken.getTokenName()]?.long.isClosed ?? true)
          return true;
        if (state.prices[selectedToken.getTokenName()]!.long.price == 0)
          return true;
        return false;
      } else {
        if (state.prices[selectedToken.getTokenName()]?.short.isClosed ?? true)
          return true;
        if (state.prices[selectedToken.getTokenName()]!.short.price == 0)
          return true;
        return false;
      }
      // return state.prices[selectedToken.getTokenName()].short.isClosed ??
      //     false;
    }
    return true;
  }

  double computeToPrice(String s) {
    double res;
    if (isBuy()) {
      if (state.mode == Mode.LONG)
        res = double.tryParse(s)! /
            state.prices[state.toToken!.getTokenName()]!.long.price;
      else
        res = double.tryParse(s)! /
            state.prices[state.toToken!.getTokenName()]!.short.price;
    } else {
      if (state.mode == Mode.LONG)
        res = double.tryParse(s)! *
            state.prices[state.fromToken.getTokenName()]!.long.price;
      else
        res = double.tryParse(s)! *
            state.prices[state.fromToken.getTokenName()]!.short.price;
    }
    return res;
  }

  Future<String> getRemCap() async {
    return await state.service.getUsedCap();
  }

  bool isBuy();

  bool checkMarketStatus() {
    List closedDays = ['Sat', 'Sun'];
    var f = DateFormat('EEE,HH,mm');
    var date = f.format(getNYC());
    List arr = date.split(',');
    if (closedDays.contains(arr[0])) return true;
    if ((int.parse(arr[1]) == 6 &&
            int.parse(arr[2]) > 30 &&
            int.parse(arr[1]) < 20) ||
        (int.parse(arr[1]) > 6 && int.parse(arr[1]) < 20)) return false;
    return true;
  }

  DateTime getNYC() {
    return DateTime.now().toUtc().subtract(Duration(hours: 4));
  }

  marketTimerFinished() {}

  Future<Transaction?> makeBuyTransaction() async {
    assert(!state.isInProgress);
    emit(SyntheticsTransactionPendingState(state));
    String tokenAddress = await getTokenAddress(state.toToken!);
    List<ContractInputData> oracles = await state.syncData.getContractInputData(
        tokenAddress,
        await state.service.ethService.ethClient.getBlockNumber());
    if (oracles.length >= 2) {
      //sort oracles on price and then on oracle number
      List arr = [];
      oracles.asMap().forEach((index, element) {
        arr.add([index, element.getPrice()]);
      });
      arr.sort((a, b) => b[1].compareTo(a[1]));

      List<ContractInputData> inputOracles;
      if (arr[0][0] < arr[1][0]) {
        inputOracles = [oracles[arr[0][0]], oracles[arr[1][0]]];
      } else {
        inputOracles = [oracles[arr[1][0]], oracles[arr[0][0]]];
      }
      String maxPrice = arr[0][1].toString();
      Transaction? transaction = await state.service.makeBuyTransaction(
          tokenAddress, state.toValue.toStringAsFixed(18), inputOracles,
          maxPrice: maxPrice);
      emit(SyntheticsTransactionFinishedState(state));
      if (transaction != null) return transaction;
    }
    emit(SyntheticsTransactionFinishedState(state,
        transactionStatus: TransactionStatus(
            "Buy ${state.toFieldController.text} ${state.toToken!.getTokenName()}",
            Status.FAILED,
            "Transaction Failed")));
    return null;
  }

  Future<Transaction?> makeSellTransaction() async {
    assert(!state.isInProgress);
    emit(SyntheticsTransactionPendingState(state));
    String tokenAddress = await getTokenAddress(state.fromToken);
    List<ContractInputData> oracles = await state.syncData.getContractInputData(
        tokenAddress,
        await state.service.ethService.ethClient.getBlockNumber());
    if (oracles.length >= 2) {
      //sort oracles on price and then on oracle number
      List arr = [];
      oracles.asMap().forEach((index, element) {
        arr.add([index, element.getPrice()]);
      });
      arr.sort((a, b) => a[1].compareTo(b[1]));

      List<ContractInputData> inputOracles;
      if (arr[0][0] < arr[1][0]) {
        inputOracles = [oracles[arr[0][0]], oracles[arr[1][0]]];
      } else {
        inputOracles = [oracles[arr[1][0]], oracles[arr[0][0]]];
      }

      Transaction? transaction = await state.service.makeSellTransaction(
          tokenAddress, state.fromFieldController.text, inputOracles);
      emit(SyntheticsTransactionFinishedState(state));
      if (transaction != null) return transaction;
    }
    emit(SyntheticsTransactionFinishedState(state,
        transactionStatus: TransactionStatus(
            "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
            Status.FAILED,
            "Transaction Failed")));
    return null;
  }

  Future<Transaction?> makeApproveTransaction() async {
    assert(!state.isInProgress);
    emit(SyntheticsTransactionPendingState(state));
    return await state.service
        .makeApproveTransaction(await getTokenAddress(state.fromToken));
  }
}
