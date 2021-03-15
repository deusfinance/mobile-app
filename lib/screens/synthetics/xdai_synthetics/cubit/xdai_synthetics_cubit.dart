import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/data_source/stock_data.dart';
import 'package:deus_mobile/data_source/xdai_stock_data.dart';
import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/models/synthetics/stock_address.dart';
import 'package:deus_mobile/models/synthetics/xdai_contract_input_data.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_state.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';

class XDaiSyntheticsCubit extends Cubit<XDaiSyntheticsState> {
  XDaiSyntheticsCubit() : super(XDaiSyntheticsInitialState());

  init() async {
    emit(XDaiSyntheticsLoadingState(state));
    //TODO check market closed
    bool res1 = await XDaiStockData.getData();
    bool res2 = await XDaiStockData.getStockAddresses();
    if (res1 && res2) {
      (state.fromToken as CryptoCurrency).balance =
          await getTokenBalance(state.fromToken);
      emit(XDaiSyntheticsSelectAssetState(state));
      state.streamController.stream
          .transform(debounce(Duration(milliseconds: 500)))
          .listen((s) async {
        if (state is XDaiSyntheticsAssetSelectedState) {
          emit(XDaiSyntheticsAssetSelectedState(state, isInProgress: true));
          if (double.tryParse(s) != null && double.tryParse(s) > 0) {
            //TODO get price
            String value = "0.0";
            state.toFieldController.text = EthereumService.formatDouble(value);
          } else {
            state.toFieldController.text = "0.0";
          }
          emit(XDaiSyntheticsAssetSelectedState(state, isInProgress: false));
        }
      });
    } else {
      emit(XDaiSyntheticsErrorState(state));
    }
  }

  Future getTokenBalance(Token token) async {
    String tokenAddress;
    if (token.getTokenName() == "xdai") {
      tokenAddress = "0x0000000000000000000000000000000000000001";
    } else {
      StockAddress stockAddress = XDaiStockData.getStockAddress(token);
      if (state.mode == Mode.LONG) {
        tokenAddress = stockAddress.long;
      } else if (state.mode == Mode.SHORT) {
        tokenAddress = stockAddress.short;
      }
    }
    return await state.service.getTokenBalance(tokenAddress);
  }

  Future getAllowances() async {
    emit(XDaiSyntheticsAssetSelectedState(state,
        approved: false, isInProgress: true));
    String tokenAddress = getTokenAddress(state.fromToken);
    if (state.fromToken.getTokenName() == "xdai") {
      (state.fromToken as CryptoCurrency).allowances =
          await state.service.getAllowances(tokenAddress);
      if ((state.fromToken as CryptoCurrency).getAllowances() > BigInt.zero)
        emit(XDaiSyntheticsAssetSelectedState(state,
            approved: true, isInProgress: false));
      else
        emit(XDaiSyntheticsAssetSelectedState(state,
            approved: false, isInProgress: false));
    } else {
      if (state.mode == null || state.mode == Mode.LONG) {
        (state.fromToken as Stock).longAllowances =
            await state.service.getAllowances(tokenAddress);
        if ((state.fromToken as Stock).getAllowances() > BigInt.zero)
          emit(XDaiSyntheticsAssetSelectedState(state,
              approved: true, isInProgress: false));
        else
          emit(XDaiSyntheticsAssetSelectedState(state,
              approved: false, isInProgress: false));
      } else if (state.mode == Mode.SHORT) {
        (state.fromToken as Stock).shortAllowances =
            await state.service.getAllowances(tokenAddress);
        if ((state.fromToken as Stock).getAllowances() > BigInt.zero)
          emit(XDaiSyntheticsAssetSelectedState(state,
              approved: true, isInProgress: false));
        else
          emit(XDaiSyntheticsAssetSelectedState(state,
              approved: false, isInProgress: false));
      }
    }
  }

  String getPriceRatio() {
    double a = double.tryParse(state.fromFieldController.text) ?? 0;
    double b = double.tryParse(state.toFieldController.text) ?? 0;
    if (a != 0 && b != 0) {
      if (state.isPriceRatioForward)
        return EthereumService.formatDouble((a / b).toString(), 5);
      return EthereumService.formatDouble((b / a).toString(), 5);
    }
    return "0.0";
  }

  String getTokenAddress(Token token) {
    String tokenAddress;
    if (token.getTokenName() == "xdai") {
      tokenAddress = "0x0000000000000000000000000000000000000001";
    } else {
      StockAddress stockAddress = XDaiStockData.getStockAddress(token);
      if (state.mode == Mode.LONG) {
        tokenAddress = stockAddress.long;
      } else if (state.mode == Mode.SHORT) {
        tokenAddress = stockAddress.short;
      }
    }
    return tokenAddress;
  }

  fromTokenChanged(Token selectedToken) async {
    state.toToken = CurrencyData.xdai;
    state.fromToken = selectedToken;
    (state.fromToken as Stock).mode = Mode.LONG;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";

    emit(XDaiSyntheticsAssetSelectedState(state,
        fromToken: selectedToken, mode: Mode.LONG));

    await getAllowances();
    (selectedToken as Stock).longBalance = await getTokenBalance(selectedToken);
    emit(XDaiSyntheticsAssetSelectedState(state, fromToken: selectedToken));
  }

  toTokenChanged(Token selectedToken) async {
    state.fromToken = CurrencyData.xdai;
    state.toToken = selectedToken;
    (state.toToken as Stock).mode = Mode.LONG;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";

    emit(XDaiSyntheticsAssetSelectedState(state,
        toToken: selectedToken, mode: Mode.LONG));

    await getAllowances();
    (selectedToken as Stock).longBalance = await getTokenBalance(selectedToken);

    emit(XDaiSyntheticsAssetSelectedState(state, toToken: selectedToken));
  }

  addListenerToFromField() {
    if (!state.fromFieldController.hasListeners) {
      state.fromFieldController.addListener(() {
        listenInput();
      });
    }
  }

  listenInput() async {
    if (state is XDaiSyntheticsAssetSelectedState) {
      String input = state.fromFieldController.text;
      if (input == null || input.isEmpty) {
        input = "0.0";
      }
      if (state.fromToken is CryptoCurrency) {
        if ((state.fromToken as CryptoCurrency).getAllowances() >=
            EthereumService.getWei(input, state.fromToken.getTokenName())) {
          state.streamController.add(input);
          emit(XDaiSyntheticsAssetSelectedState(state, approved: true));
        } else {
          state.streamController.add(input);
          emit(XDaiSyntheticsAssetSelectedState(state, approved: false));
        }
      } else {
        if ((state.fromToken as Stock).getAllowances() >=
            EthereumService.getWei(input, state.fromToken.getTokenName())) {
          state.streamController.add(input);
          emit(XDaiSyntheticsAssetSelectedState(state, approved: true));
        } else {
          state.streamController.add(input);
          emit(XDaiSyntheticsAssetSelectedState(state, approved: false));
        }
      }
    }
  }

  reverseSwap() {
    Token a = state.fromToken;
    state.fromToken = state.toToken;
    state.toToken = a;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    getAllowances();
  }

  reversePriceRatio() {
    emit(XDaiSyntheticsAssetSelectedState(state,
        isPriceRatioForward: !state.isPriceRatioForward));
  }

  void setMode(Mode mode) {
    if (state is XDaiSyntheticsAssetSelectedState) {
      if (state.toToken is Stock) {
        (state.toToken as Stock).mode = mode;
      } else {
        (state.fromToken as Stock).mode = mode;
      }
      emit(XDaiSyntheticsAssetSelectedState(state, mode: mode));
    }
  }

  void closeToast() {
    if (state is XDaiSyntheticsTransactionPendingState)
      emit(XDaiSyntheticsTransactionPendingState(state, showingToast: false));
    else if (state is XDaiSyntheticsTransactionFinishedState)
      emit(XDaiSyntheticsTransactionFinishedState(state, showingToast: false));
  }

  Future approve() async {
    if (!state.isInProgress) {
      emit(XDaiSyntheticsTransactionPendingState(state,
          transactionStatus: TransactionStatus(
              "Approve ${state.fromToken.name}",
              Status.PENDING,
              "Transaction Pending")));

      try {
        var res = await state.service.approve(getTokenAddress(state.fromToken));
        Stream<TransactionReceipt> result =
            state.service.ethService.pollTransactionReceipt(res);
        result.listen((event) {
          state.approved = event.status;
          if (event.status) {
            state.approved = true;
            emit(XDaiSyntheticsTransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    "Approve ${state.fromToken.name}",
                    Status.SUCCESSFUL,
                    "Transaction Successfull",
                    res)));
          } else {
            emit(XDaiSyntheticsTransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    "Approve ${state.fromToken.name}",
                    Status.FAILED,
                    "Transaction Failed",
                    res)));
          }
        });
      } on Exception catch (value) {
        state.approved = false;
        emit(XDaiSyntheticsTransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Approve ${state.fromToken.name}",
                Status.FAILED,
                "Transaction Failed")));
      }
    }
  }

  Future sell() async {
    if (state.approved && !state.isInProgress) {
      emit(XDaiSyntheticsTransactionPendingState(state,
          transactionStatus: TransactionStatus(
              "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}}",
              Status.PENDING,
              "Transaction Pending")));
      String tokenAddress = getTokenAddress(state.fromToken);

      List<XDaiContractInputData> oracles =
          await XDaiStockData.getContractInputData(tokenAddress);
      if (oracles.length >= 2) {
        try {
          oracles.sort((a, b) => b.getPrice().compareTo(a.getPrice()));
          var res = await state.service.sell(tokenAddress,
              state.fromFieldController.text, oracles.sublist(0, 1));
          Stream<TransactionReceipt> result =
              state.service.ethService.pollTransactionReceipt(res);
          result.listen((event) {
            if (event.status) {
              emit(XDaiSyntheticsTransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                      Status.SUCCESSFUL,
                      "Transaction Successfull",
                      res)));
            } else {
              emit(XDaiSyntheticsTransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                      Status.FAILED,
                      "Transaction Failed",
                      res)));
            }
          });
        } on Exception catch (_) {
          emit(XDaiSyntheticsTransactionFinishedState(state,
              transactionStatus: TransactionStatus(
                  "Sell ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                  Status.FAILED,
                  "Transaction Failed")));
        }
      } else {
        emit(XDaiSyntheticsTransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "oracles not available", Status.FAILED, "Transaction Failed")));
      }
    }
  }

  Future buy() async {
    if (!state.isInProgress) {
      emit(XDaiSyntheticsTransactionPendingState(state,
          transactionStatus: TransactionStatus(
              "Buy ${state.toFieldController.text} ${state.toToken.getTokenName()}",
              Status.PENDING,
              "Transaction Pending")));
      String tokenAddress = getTokenAddress(state.toToken);

      List<XDaiContractInputData> oracles =
          await XDaiStockData.getContractInputData(tokenAddress);
      if (oracles.length >= 2) {
        try {
          //get to gerantar
          oracles.sort((a, b) => a.getPrice().compareTo(b.getPrice()));
          String maxPrice = oracles[0].price;
          var res = await state.service.buy(tokenAddress,
              state.toFieldController.text, oracles.sublist(0, 1), maxPrice);

          Stream<TransactionReceipt> result =
              state.service.ethService.pollTransactionReceipt(res);
          result.listen((event) {
            if (event.status) {
              emit(XDaiSyntheticsTransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Buy ${state.toFieldController.text} ${state.toToken.getTokenName()}",
                      Status.SUCCESSFUL,
                      "Transaction Successfull",
                      res)));
            } else {
              emit(XDaiSyntheticsTransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Buy ${state.toFieldController.text} ${state.toToken.getTokenName()}",
                      Status.FAILED,
                      "Transaction Failed",
                      res)));
            }
          });
        } on Exception catch (_) {
          emit(XDaiSyntheticsTransactionFinishedState(state,
              transactionStatus: TransactionStatus(
                  "Buy ${state.toFieldController.text} ${state.toToken.getTokenName()}",
                  Status.FAILED,
                  "Transaction Failed")));
        }
      } else {
        emit(XDaiSyntheticsTransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "oracles not available", Status.FAILED, "Transaction Failed")));
      }
    }
  }
}
