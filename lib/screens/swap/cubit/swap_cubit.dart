import 'dart:async';

import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/transaction.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_state.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/service/address_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';

class SwapCubit extends Cubit<SwapState> {
  SwapCubit() : super(SwapInitial());

  init({SwapState? swapState}) async {
    if (swapState != null) {
      swapState.refreshController = RefreshController(initialRefresh: false);
      addListenerToFromField(swapState);
      emit(swapState);
    } else {
      emit(SwapLoading(state));
      await fetchBalances();
      state.database = await AppDatabase.getInstance();
      addListenerToFromField(state);
      emit(SwapLoaded(state));
    }
  }

  fromTokenChanged(Token selectedToken) async {
    if (state.toToken.getTokenName() == selectedToken.getTokenName()) {
      if (selectedToken.getTokenName() == "eth") {
        state.toToken = CurrencyData.deus;
      } else {
        state.toToken = CurrencyData.eth;
      }
    }
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;

    emit(SwapLoaded(state, fromToken: selectedToken));

    await getAllowances();
    state.fromToken.balance = await getTokenBalance(selectedToken);
    emit(SwapLoading(state));
    emit(SwapLoaded(state, fromToken: state.fromToken));
  }

  toTokenChanged(Token selectedToken) async {
    bool fromTokenChanged = false;
    if (selectedToken.getTokenName() == state.fromToken.getTokenName()) {
      fromTokenChanged = true;
      if (selectedToken.getTokenName() == "eth") {
        state.fromToken = CurrencyData.deus;
      } else {
        state.fromToken = CurrencyData.eth;
      }
    }
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;
    emit(SwapLoaded(state, toToken: selectedToken));
    state.toToken.balance = await getTokenBalance(selectedToken);
    emit(SwapLoading(state));
    emit(SwapLoaded(state, toToken: selectedToken));
    if (fromTokenChanged) getAllowances();
  }

  approve(Gas? gas) async {
    if (!state.isInProgress) {
      if (gas != null) {
        DbTransaction? transaction;
        try {
          var res = await state.swapService
              .approve(state.fromToken.getTokenName(), gas);

          emit(TransactionPendingState(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.fromToken.name}",
                  Status.PENDING,
                  "Transaction Pending",
                  res)));

          transaction = new DbTransaction(
              walletAddress:
                  (await locator<AddressService>().getPublicAddress()).hex,
              chainId: 1,
              hash: res,
              type: TransactionType.APPROVE.index,
              title: state.fromToken.symbol);
          List<int> ids = await state.database!.transactionDao
              .insertDbTransaction([transaction]);
          transaction.id = ids[0];

          Stream<TransactionReceipt> result =
              state.swapService.ethService.pollTransactionReceipt(res);
          result.listen((event) async {
            state.approved = event.status!;
            if (event.status!) {
              state.approved = true;
              emit(TransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Approve ${state.fromToken.name}",
                      Status.SUCCESSFUL,
                      "Transaction Successful",
                      res)));
            } else {
              emit(TransactionFinishedState(state,
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
                walletAddress:
                    (await locator<AddressService>().getPublicAddress()).hex,
                chainId: 1,
                hash: "",
                type: TransactionType.APPROVE.index,
                title: state.fromToken.symbol);
            List<int> ids = await state.database!.transactionDao
                .insertDbTransaction([transaction]);
            transaction.id = ids[0];
          }

          emit(TransactionFinishedState(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.fromToken.name}",
                  Status.FAILED,
                  "Transaction Failed")));
        }
      } else {
        state.approved = false;
        emit(TransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Approve ${state.fromToken.name}",
                Status.FAILED,
                "Transaction Rejected")));
      }
    } else {
      state.approved = false;
      emit(TransactionFinishedState(state,
          transactionStatus: TransactionStatus(
              "Approve ${state.fromToken.name}",
              Status.FAILED,
              "Transaction Failed")));
    }
  }

  Future swapTokens(Gas? gas) async {
    if (state.approved && !state.isInProgress) {
      if (gas != null) {
        DbTransaction? transaction;
        try {
          var res = await state.swapService.swapTokens(
              state.fromToken.getTokenName(),
              state.toToken.getTokenName(),
              state.fromFieldController.text,
              ((1 - getSlippage()) * state.toValue).toString(),
              gas);

          emit(TransactionPendingState(state,
              transactionStatus: TransactionStatus(
                  "Swap ${state.toFieldController.text} ${state.toToken.getTokenName()} for ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                  Status.PENDING,
                  "Transaction Pending",
                  res)));


          transaction = new DbTransaction(
              walletAddress: (await locator<AddressService>().getPublicAddress()).hex,
              chainId: 1,
              hash: res,
              type: TransactionType.SWAP.index,
              title: "${state.fromToken.symbol} to ${state.toToken.symbol}");
          List<int> ids = await state.database!.transactionDao
              .insertDbTransaction([transaction]);
          transaction.id = ids[0];

          Stream<TransactionReceipt> result =
              state.swapService.ethService.pollTransactionReceipt(res);
          result.listen((event) async {
            transaction!.isSuccess = event.status;
            int ids = await state.database!.transactionDao
                .updateDbTransactions([transaction]);

            if (event.status!) {
              String fromBalance = await getTokenBalance(state.fromToken);
              String toBalance = await getTokenBalance(state.toToken);
              state.fromToken.balance = fromBalance;
              state.toToken.balance = toBalance;

              //TODO
              String walletAddress =
                  (await locator<AddressService>().getPublicAddress()).hex;
              String tokenAddress = await state.swapService.ethService
                  .getTokenAddrHex(state.toToken.getTokenName(), "token");
              WalletAsset? ws = await state.database!.walletAssetDao
                  .getWalletAsset(1, tokenAddress, walletAddress);

              if (ws == null) {
                CryptoCurrency? cryptoCurrency;
                CurrencyData.all.forEach((element) {
                  if (element.getTokenName() == state.toToken.getTokenName()) {
                    cryptoCurrency = element;
                  }
                });
                if (cryptoCurrency != null) {
                  WalletAsset walletAsset = new WalletAsset(
                      walletAddress:
                          (await locator<AddressService>().getPublicAddress())
                              .hex,
                      chainId: 1,
                      tokenAddress: tokenAddress,
                      tokenSymbol: cryptoCurrency!.symbol,
                      logoPath: cryptoCurrency!.logoPath,
                      valueWhenInserted: 0);
                  await state.database!.walletAssetDao
                      .insertWalletAsset([walletAsset]);
                }
              }

              emit(TransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Swapped your ${state.fromFieldController.text} ${state.fromToken.getTokenName()} for ${state.toFieldController.text} ${state.toToken.getTokenName()}",
                      Status.SUCCESSFUL,
                      "Transaction Successful",
                      res)));
            } else {
              emit(TransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Not Swapped your ${state.fromFieldController.text} ${state.fromToken.getTokenName()} for ${state.toFieldController.text} ${state.toToken.getTokenName()}",
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
                walletAddress: (await locator<AddressService>().getPublicAddress()).hex,
                chainId: 1,
                hash: "",
                isSuccess: false,
                type: TransactionType.SELL.index,
                title: "${state.fromToken.symbol} to ${state.toToken.symbol}");
            List<int> ids = await state.database!.transactionDao
                .insertDbTransaction([transaction]);
            transaction.id = ids[0];
          }

          emit(TransactionFinishedState(state,
              transactionStatus: TransactionStatus(
                  "Not Swapped your ${state.fromFieldController.text} ${state.fromToken.getTokenName()} for ${state.toFieldController.text} ${state.toToken.getTokenName()}",
                  Status.FAILED,
                  "Transaction Failed")));
        }
      } else {
        emit(TransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Rejected", Status.FAILED, "Transaction Failed")));
      }
    }
  }

  Future getTokenBalance(Token token) async {
    return await state.swapService.getTokenBalance(token.getTokenName());
  }

  reverseSwap() {
    CryptoCurrency a = state.fromToken;
    state.fromToken = state.toToken;
    state.toToken = a;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;
    getAllowances();
  }

  reversePriceRatio() {
    emit(SwapLoaded(state, isPriceRatioForward: !state.isPriceRatioForward));
  }

  setSlippage(double s) {
    state.slippageController.text = "";
    emit(SwapLoaded(state, slippage: s));
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

  addListenerToFromField(SwapState s) {
    s.fromFieldController =
        new TextEditingController(text: s.fromFieldController.text);
    s.toFieldController =
        new TextEditingController(text: s.toFieldController.text);
    s.streamController = new StreamController();
    s.fromFieldController.addListener(listenInput);
    s.streamController.stream
        .debounce(Duration(milliseconds: 500))
        .listen((s) async {
      emit(SwapLoaded(state, isInProgress: true));
      if (double.tryParse(s)! > 0) {
        state.swapService
            .getAmountsOut(
                state.fromToken.getTokenName(), state.toToken.getTokenName(), s)
            .then((value) {
          state.toValue = double.tryParse(value)!;
          state.toFieldController.text = EthereumService.formatDouble(value);
        });
      } else {
        state.toValue = 0;
        state.toFieldController.text = "0.0";
      }
      emit(SwapLoaded(state, isInProgress: false));
    });
  }

  addListenerToSlippageController() {
    if (!state.slippageController.hasListeners) {
      state.slippageController.addListener(() {
        try {
          double slippage = double.parse(state.slippageController.text);
          emit(SwapLoaded(state, slippage: slippage));
        } on Exception catch (value) {
          emit(SwapLoaded(state, slippage: 0.5));
        }
      });
    }
  }

  Future<double> computePriceImpact() async {
    try {
      double x = double.parse(await state.swapService.getAmountsOut(
          state.fromToken.getTokenName(), state.toToken.getTokenName(), "0.1"));
      double r = 0.1;
      double input = double.tryParse(state.fromFieldController.text) ?? 0;
      double y = state.toValue;

      double v = 1.0;
      if (input != 0) {
        v = y / (x * (input / r));
      }
      return double.parse(((1.0 - v) * 100.0).toStringAsFixed(3));
    } on Exception catch (value) {
      return 0.0;
    }
  }

  listenInput() async {
    String input = state.fromFieldController.text;
    if (input == null || input.isEmpty) {
      input = "0.0";
    }
    if (state.fromToken.getAllowances() >=
        EthereumService.getWei(input, state.fromToken.getTokenName())) {
      state.streamController.add(input);
      emit(SwapLoaded(state, approved: true));
    } else {
      state.streamController.add(input);
      emit(SwapLoaded(state, approved: false));
    }
  }

  Future<Transaction?> makeTransaction() async {
    Transaction? transaction = await state.swapService.makeSwapTransaction(
        state.fromToken.getTokenName(),
        state.toToken.getTokenName(),
        state.fromFieldController.text,
        ((1 - getSlippage()) * state.toValue).toString());
    return transaction;
  }

  fetchBalances() async {
    state.fromToken.balance =
        await state.swapService.getTokenBalance(state.fromToken.getTokenName());
    state.toToken.balance =
        await state.swapService.getTokenBalance(state.toToken.getTokenName());
    await getAllowances();
  }

  getAllowances() async {
    emit(SwapLoaded(state, approved: false, isInProgress: true));
    state.fromToken.allowances =
        await state.swapService.getAllowances(state.fromToken.getTokenName());
    if (state.fromToken.getAllowances() > BigInt.zero)
      emit(SwapLoaded(state, approved: true, isInProgress: false));
    else
      emit(SwapLoaded(state, approved: false, isInProgress: false));
  }

  getSlippage() {
    return state.slippage / 100;
  }

  Future<List<Token>> getRoute() async {
    List<String> value = await state.swapService
        .getPath(state.fromToken.getTokenName(), state.toToken.getTokenName());
    List<Token> r = [];
    value.forEach((addr) {
      r.add(EthereumService.addressToTokenMap[addr.toLowerCase()]!);
    });
    return r;
  }

  void closeToast() {
    if (state is TransactionPendingState)
      emit(TransactionPendingState(state, showingToast: false));
    else if (state is TransactionFinishedState)
      emit(TransactionFinishedState(state, showingToast: false));
  }

  Future<Transaction?> makeApproveTransaction() async {
    Transaction? transaction = await state.swapService
        .makeApproveTransaction(state.fromToken.getTokenName());
    return transaction;
  }

  void refresh() async{
    state.refreshController.refreshCompleted();
    emit(SwapInitial());
    await init();
  }
}
