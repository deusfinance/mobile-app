import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/database/database.dart';
import '../../core/database/transaction.dart';
import '../../core/database/wallet_asset.dart';
import '../../locator.dart';
import '../../models/swap/crypto_currency.dart';
import '../../models/swap/gas.dart';
import '../../models/synthetics/stock.dart';
import '../../models/synthetics/stock_address.dart';
import '../../models/synthetics/contract_input_data.dart';
import '../../models/token.dart';
import '../../models/transaction_status.dart';
import 'synthetics_state.dart';
import '../../service/address_service.dart';
import '../../service/ethereum_service.dart';
import '../../service/sync/heco_stock_service.dart';
import '../../service/sync/matic_stock_service.dart';
import '../../service/sync/xdai_stock_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';
import 'package:intl/intl.dart';

abstract class SyntheticsCubit extends Cubit<SyntheticsState> {
  SyntheticsCubit(SyntheticsChain chain) : super(SyntheticsInitialState(chain));

  Future<void> init({SyntheticsState? syntheticsState}) async {
    if (syntheticsState != null) {
      syntheticsState.refreshController =
          new RefreshController(initialRefresh: false);
      addListenerToFromField(syntheticsState);
      emit(syntheticsState);
    } else {
      emit(SyntheticsLoadingState(state));
      final bool res1 = await state.syncData.getData();
      state.prices = await state.syncData.getPrices();
      if (res1 && state.prices.isNotEmpty) {
        state.marketTimerClosed = checkMarketStatus();
        (state.fromToken as CryptoCurrency).balance =
            await getTokenBalance(state.fromToken);
        state.database = await AppDatabase.getInstance();

        state.timer = new Timer.periodic(
            const Duration(seconds: 14), (Timer t) => getPrices());
        addListenerToFromField(state);
        emit(SyntheticsSelectAssetState(state));
      } else {
        emit(SyntheticsErrorState(state));
      }
    }
  }

  void refresh() async {
    state.refreshController.refreshCompleted();
    emit(SyntheticsInitialState(state.syntheticsChain));
    await init();
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
      final StockAddress? stockAddress = state.syncData.getStockAddress(token);
      if (state.mode == Mode.LONG) {
        tokenAddress = stockAddress!.long;
      } else if (state.mode == Mode.SHORT) {
        tokenAddress = stockAddress!.short;
      }
    }
    return tokenAddress;
  }

  DateTime marketStatusChanged() {
    final DateTime now = getNYC();
    final List closedDays = ['Sat', 'Sun'];
    final f = DateFormat('EEE,HH,mm,ss');
    final date = f.format(now);
    final List arr = date.split(',');
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
            .add(const Duration(days: 3));
      }
    } else if (arr[0] == "Sat") {
      return DateTime.utc(now.year, now.month, now.day, 6, 30)
          .add(const Duration(days: 2));
    } else if (arr[0] == "Sun") {
      return DateTime.utc(now.year, now.month, now.day, 6, 30)
          .add(const Duration(days: 1));
    } else {
      if (int.parse(arr[1]) < 6 ||
          (int.parse(arr[1]) == 6 && int.parse(arr[2]) < 30)) {
        return DateTime.utc(now.year, now.month, now.day, 6, 30);
      } else {
        return DateTime.utc(now.year, now.month, now.day, 6, 30)
            .add(const Duration(days: 1));
      }
    }
  }

  Future getTokenBalance(Token token) async {
    final String tokenAddress = await getTokenAddress(token);
    return await state.service.getTokenBalance(tokenAddress);
  }

  Future getAllowances() async {
    emit(SyntheticsAssetSelectedState(state,
        approved: false, isInProgress: true));
    final String? tokenAddress = await getTokenAddress(state.fromToken);
    if (isBuy()) {
      (state.fromToken as CryptoCurrency).allowances =
          await state.service.getAllowances(tokenAddress!);
      if ((state.fromToken as CryptoCurrency).getAllowances() > BigInt.zero)
        emit(SyntheticsAssetSelectedState(state,
            approved: true, isInProgress: false));
      else
        emit(SyntheticsAssetSelectedState(state,
            approved: false, isInProgress: false));
    } else {
      if (state.mode == Mode.LONG) {
        (state.fromToken as Stock).longAllowances =
            await state.service.getAllowances(tokenAddress!);
        if ((state.fromToken as Stock).getAllowances()! > BigInt.zero)
          emit(SyntheticsAssetSelectedState(state,
              approved: true, isInProgress: false));
        else
          emit(SyntheticsAssetSelectedState(state,
              approved: false, isInProgress: false));
      } else if (state.mode == Mode.SHORT) {
        (state.fromToken as Stock).shortAllowances =
            await state.service.getAllowances(tokenAddress!);
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
    final double a = double.tryParse(state.fromFieldController.text) ?? 0;
    final double b = state.toValue;
    if (a != 0 && b != 0) {
      if (state.isPriceRatioForward)
        return EthereumService.formatDouble((a / b).toString(), 5);
      return EthereumService.formatDouble((b / a).toString(), 5);
    }
    return "0.0";
  }

  Future<void> fromTokenChanged(Token selectedToken) async {
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

  Future<void> toTokenChanged(Token selectedToken) async {
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

  void addListenerToFromField(SyntheticsState s) {
    s.fromFieldController =
        new TextEditingController(text: s.fromFieldController.text);
    s.toFieldController =
        new TextEditingController(text: s.toFieldController.text);
    s.inputController = new StreamController();
    s.fromFieldController.addListener(listenInput);
    s.inputController.stream
        .debounce(const Duration(milliseconds: 500))
        .listen((s) {
      if (!(state is SyntheticsSelectAssetState)) {
        emit(SyntheticsAssetSelectedState(state, isInProgress: true));
        if (double.tryParse(s)! > 0) {
          final double value = computeToPrice(s);
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

  Future<void> listenInput() async {
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

  void reverseSync() {
    final Token a = state.fromToken;
    state.fromToken = state.toToken!;
    state.toToken = a;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;
    getAllowances();
  }

  void reversePriceRatio() {
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
        await listenInput();
      }
    }
  }

  void closeToast() {
    state.isInProgress = false;
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
          final res = await state.service
              .approve(await getTokenAddress(state.fromToken), gas);
          transaction = new DbTransaction(
              walletAddress:
                  (await locator<AddressService>().getPublicAddress()).hex,
              chainId: getChainId(),
              hash: res,
              type: TransactionType.APPROVE.index,
              title: state.fromToken is CryptoCurrency
                  ? state.fromToken.symbol
                  : state.mode == Mode.SHORT
                      ? (state.fromToken as Stock).shortSymbol
                      : (state.fromToken as Stock).longSymbol);
          final List<int> ids = await state.database!.transactionDao
              .insertDbTransaction([transaction]);
          transaction.id = ids[0];
          emit(SyntheticsTransactionPendingState(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.fromToken.name}",
                  Status.PENDING,
                  "Transaction Pending",
                  res)));
          final Stream<TransactionReceipt> result =
              state.service.ethService.pollTransactionReceipt(res);
          result.listen((event) async {
            state.approved = event.status!;
            if (event.status!) {
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
        } on Exception {
          state.approved = false;

          if (transaction != null) {
            transaction.isSuccess = false;
            await state.database!.transactionDao
                .updateDbTransactions([transaction]);
          } else {
            transaction = new DbTransaction(
                walletAddress:
                    (await locator<AddressService>().getPublicAddress()).hex,
                chainId: getChainId(),
                hash: "",
                type: TransactionType.APPROVE.index,
                title: state.fromToken is CryptoCurrency
                    ? state.fromToken.symbol
                    : state.mode == Mode.SHORT
                        ? (state.fromToken as Stock).shortSymbol
                        : (state.fromToken as Stock).longSymbol);
            final List<int> ids = await state.database!.transactionDao
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
        final String tokenAddress = await getTokenAddress(state.fromToken);

        final List<ContractInputData> oracles = await state.syncData
            .getContractInputData(tokenAddress,
                await state.service.ethService.ethClient.getBlockNumber());
        if (oracles.length >= 2) {
          DbTransaction? transaction;
          try {
            //sort oracles on price and then on oracle number
            final List arr = [];
            oracles.asMap().forEach((index, element) {
              arr.add([index, element.getPrice()]);
            });
            // ignore: avoid_dynamic_calls
            arr.sort((a, b) => a[1].compareTo(b[1]));

            List<ContractInputData> inputOracles;
            // ignore: avoid_dynamic_calls
            if (arr[0][0] < arr[1][0]) {
              // ignore: avoid_dynamic_calls
              inputOracles = [oracles[arr[0][0]], oracles[arr[1][0]]];
            } else {
              // ignore: avoid_dynamic_calls
              inputOracles = [oracles[arr[1][0]], oracles[arr[0][0]]];
            }

            final res = await state.service.sell(tokenAddress,
                state.fromFieldController.text, inputOracles, gas);

            transaction = new DbTransaction(
                walletAddress:
                    (await locator<AddressService>().getPublicAddress()).hex,
                chainId: getChainId(),
                hash: res,
                type: TransactionType.SELL.index,
                title: state.fromToken is CryptoCurrency
                    ? state.fromToken.symbol
                    : state.mode == Mode.SHORT
                        ? (state.fromToken as Stock).shortSymbol
                        : (state.fromToken as Stock).longSymbol);
            final List<int> ids = await state.database!.transactionDao
                .insertDbTransaction([transaction]);
            transaction.id = ids[0];

            emit(SyntheticsTransactionPendingState(state,
                transactionStatus: TransactionStatus(
                    "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                    Status.PENDING,
                    "Transaction Pending",
                    res)));

            final Stream<TransactionReceipt> result =
                state.service.ethService.pollTransactionReceipt(res);
            result.listen((event) async {
              transaction!.isSuccess = event.status;
              await state.database!.transactionDao
                  .updateDbTransactions([transaction]);

              if (event.status!) {
                final String fromBalance =
                    await getTokenBalance(state.fromToken);
                final String toBalance = await getTokenBalance(state.toToken!);
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
              await state.database!.transactionDao
                  .updateDbTransactions([transaction]);
            } else {
              transaction = new DbTransaction(
                  walletAddress:
                      (await locator<AddressService>().getPublicAddress()).hex,
                  chainId: getChainId(),
                  hash: "",
                  isSuccess: false,
                  type: TransactionType.SELL.index,
                  title: state.fromToken is CryptoCurrency
                      ? state.fromToken.symbol
                      : state.mode == Mode.SHORT
                          ? (state.fromToken as Stock).shortSymbol
                          : (state.fromToken as Stock).longSymbol);
              final List<int> ids = await state.database!.transactionDao
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
        final String tokenAddress = await getTokenAddress(state.toToken!);
        final List<ContractInputData> oracles = await state.syncData
            .getContractInputData(tokenAddress,
                await state.service.ethService.ethClient.getBlockNumber());
        if (oracles.length >= 2) {
          DbTransaction? transaction;
          try {
            //sort oracles on price and then on oracle number
            final List arr = [];
            oracles.asMap().forEach((index, element) {
              arr.add([index, element.getPrice()]);
            });
            // ignore: avoid_dynamic_calls
            arr.sort((a, b) => b[1].compareTo(a[1]));

            List<ContractInputData> inputOracles;
            // ignore: avoid_dynamic_calls
            if (arr[0][0] < arr[1][0]) {
              // ignore: avoid_dynamic_calls
              inputOracles = [oracles[arr[0][0]], oracles[arr[1][0]]];
            } else {
              // ignore: avoid_dynamic_calls
              inputOracles = [oracles[arr[1][0]], oracles[arr[0][0]]];
            }
            // ignore: avoid_dynamic_calls
            final String maxPrice = arr[0][1].toString();
            var res;

            res = await state.service.buy(tokenAddress,
                state.toValue.toStringAsFixed(18), inputOracles, gas,
                maxPrice: maxPrice);

            transaction = new DbTransaction(
                walletAddress:
                    (await locator<AddressService>().getPublicAddress()).hex,
                chainId: getChainId(),
                hash: res,
                type: TransactionType.BUY.index,
                title: state.toToken is CryptoCurrency
                    ? state.toToken!.symbol
                    : state.mode == Mode.SHORT
                        ? (state.toToken as Stock).shortSymbol
                        : (state.toToken as Stock).longSymbol);
            final List<int> ids = await state.database!.transactionDao
                .insertDbTransaction([transaction]);
            transaction.id = ids[0];

            emit(SyntheticsTransactionPendingState(state,
                transactionStatus: TransactionStatus(
                    "Buy ${state.toFieldController.text} ${state.toToken!.getTokenName()}",
                    Status.PENDING,
                    "Transaction Pending",
                    res)));
            final Stream<TransactionReceipt> result =
                state.service.ethService.pollTransactionReceipt(res);
            result.listen((event) async {
              transaction!.isSuccess = event.status!;
              await state.database!.transactionDao
                  .updateDbTransactions([transaction]);
              if (event.status!) {
                final String fromBalance =
                    await getTokenBalance(state.fromToken);
                final String toBalance = await getTokenBalance(state.toToken!);
                if (state.mode == Mode.LONG)
                  (state.toToken as Stock).longBalance = toBalance;
                else
                  (state.toToken as Stock).shortBalance = toBalance;

                (state.fromToken as CryptoCurrency).balance = fromBalance;

                //TODO add to wallet
                final String walletAddress =
                    (await locator<AddressService>().getPublicAddress()).hex;
                switch (state.syntheticsChain) {
                  case SyntheticsChain.ETH:
                    final WalletAsset? ws = await state.database!.walletAssetDao
                        .getWalletAsset(1, tokenAddress, walletAddress);
                    if (ws == null) {
                      final StockAddress? stockAddress = state.syncData
                          .getStockAddressFromAddress(tokenAddress);
                      final Stock? stock =
                          state.syncData.getStockFromAddress(stockAddress!);
                      final WalletAsset walletAsset = new WalletAsset(
                          walletAddress: (await locator<AddressService>()
                                  .getPublicAddress())
                              .hex,
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
                    final WalletAsset? ws = await state.database!.walletAssetDao
                        .getWalletAsset(100, tokenAddress, walletAddress);
                    if (ws == null) {
                      final StockAddress? stockAddress = state.syncData
                          .getStockAddressFromAddress(tokenAddress);
                      final Stock? stock =
                          state.syncData.getStockFromAddress(stockAddress!);
                      final WalletAsset walletAsset = new WalletAsset(
                          walletAddress: (await locator<AddressService>()
                                  .getPublicAddress())
                              .hex,
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
                    final WalletAsset? ws = await state.database!.walletAssetDao
                        .getWalletAsset(128, tokenAddress, walletAddress);
                    if (ws == null) {
                      final StockAddress? stockAddress = state.syncData
                          .getStockAddressFromAddress(tokenAddress);
                      final Stock? stock =
                          state.syncData.getStockFromAddress(stockAddress!);
                      final WalletAsset walletAsset = new WalletAsset(
                          walletAddress: (await locator<AddressService>()
                                  .getPublicAddress())
                              .hex,
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
                    final WalletAsset? ws = await state.database!.walletAssetDao
                        .getWalletAsset(56, tokenAddress, walletAddress);
                    if (ws == null) {
                      final StockAddress? stockAddress = state.syncData
                          .getStockAddressFromAddress(tokenAddress);
                      final Stock? stock =
                          state.syncData.getStockFromAddress(stockAddress!);
                      final WalletAsset walletAsset = new WalletAsset(
                          walletAddress: (await locator<AddressService>()
                                  .getPublicAddress())
                              .hex,
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
              await state.database!.transactionDao
                  .updateDbTransactions([transaction]);
            } else {
              transaction = new DbTransaction(
                  walletAddress:
                      (await locator<AddressService>().getPublicAddress()).hex,
                  chainId: getChainId(),
                  hash: "",
                  isSuccess: false,
                  type: TransactionType.BUY.index,
                  title: state.toToken is CryptoCurrency
                      ? state.toToken!.symbol
                      : state.mode == Mode.SHORT
                          ? (state.toToken as Stock).shortSymbol
                          : (state.toToken as Stock).longSymbol);
              final List<int> ids = await state.database!.transactionDao
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
    if (state.prices.isNotEmpty) {
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
    final List closedDays = ['Sat', 'Sun'];
    final f = DateFormat('EEE,HH,mm');
    final date = f.format(getNYC());
    final List arr = date.split(',');
    if (closedDays.contains(arr[0])) return true;
    if ((int.parse(arr[1]) == 6 &&
            int.parse(arr[2]) > 30 &&
            int.parse(arr[1]) < 20) ||
        (int.parse(arr[1]) > 6 && int.parse(arr[1]) < 20)) return false;
    return true;
  }

  DateTime getNYC() {
    return DateTime.now().toUtc().subtract(const Duration(hours: 4));
  }

  // ignore: type_annotate_public_apis
  marketTimerFinished() {}

  Future<Transaction?> makeBuyTransaction() async {
    assert(!state.isInProgress);
    try {
      emit(SyntheticsTransactionPendingState(state));
      final String tokenAddress = await getTokenAddress(state.toToken!);
      final List<ContractInputData> oracles = await state.syncData
          .getContractInputData(tokenAddress,
              await state.service.ethService.ethClient.getBlockNumber());
      if (oracles.length >= 2) {
        //sort oracles on price and then on oracle number
        final List arr = [];
        oracles.asMap().forEach((index, element) {
          arr.add([index, element.getPrice()]);
        });
        // ignore: avoid_dynamic_calls
        arr.sort((a, b) => b[1].compareTo(a[1]));

        List<ContractInputData> inputOracles;
        // ignore: avoid_dynamic_calls
        if (arr[0][0] < arr[1][0]) {
          // ignore: avoid_dynamic_calls
          inputOracles = [oracles[arr[0][0]], oracles[arr[1][0]]];
        } else {
          // ignore: avoid_dynamic_calls
          inputOracles = [oracles[arr[1][0]], oracles[arr[0][0]]];
        }
        // ignore: avoid_dynamic_calls
        final String maxPrice = arr[0][1].toString();
        final Transaction? transaction = await state.service.makeBuyTransaction(
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
    } catch (e) {
      emit(SyntheticsTransactionFinishedState(state,
          transactionStatus: TransactionStatus(
              "Buy ${state.toFieldController.text} ${state.toToken!.getTokenName()}",
              Status.FAILED,
              e.toString())));
      return null;
    }
  }

  Future<Transaction?> makeSellTransaction() async {
    assert(!state.isInProgress);
    try {
      emit(SyntheticsTransactionPendingState(state));
      final String tokenAddress = await getTokenAddress(state.fromToken);
      final List<ContractInputData> oracles = await state.syncData
          .getContractInputData(tokenAddress,
              await state.service.ethService.ethClient.getBlockNumber());
      if (oracles.length >= 2) {
        //sort oracles on price and then on oracle number
        final List arr = [];
        oracles.asMap().forEach((index, element) {
          arr.add([index, element.getPrice()]);
        });
        // ignore: avoid_dynamic_calls
        arr.sort((a, b) => a[1].compareTo(b[1]));

        List<ContractInputData> inputOracles;
        // ignore: avoid_dynamic_calls
        if (arr[0][0] < arr[1][0]) {
          // ignore: avoid_dynamic_calls
          inputOracles = [oracles[arr[0][0]], oracles[arr[1][0]]];
        } else {
          // ignore: avoid_dynamic_calls
          inputOracles = [oracles[arr[1][0]], oracles[arr[0][0]]];
        }

        final Transaction? transaction = await state.service
            .makeSellTransaction(
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
    } catch (e) {
      emit(SyntheticsTransactionFinishedState(state,
          transactionStatus: TransactionStatus(
              "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
              Status.FAILED,
              e.toString())));
      return null;
    }
  }

  Future<Transaction?> makeApproveTransaction() async {
    assert(!state.isInProgress);
    try {
      emit(SyntheticsTransactionPendingState(state));
      final Transaction? tr = await state.service
          .makeApproveTransaction(await getTokenAddress(state.fromToken));
      emit(SyntheticsTransactionFinishedState(state));
      return tr;
    } catch (e) {
      emit(SyntheticsTransactionFinishedState(state,
          transactionStatus: TransactionStatus(
              "Approve ${state.fromToken.getTokenName()}",
              Status.FAILED,
              e.toString())));
      return null;
    }
  }
}
