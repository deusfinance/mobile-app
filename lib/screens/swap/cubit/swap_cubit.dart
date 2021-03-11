import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_state.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';

class SwapCubit extends Cubit<SwapState> {
  SwapCubit() : super(SwapInitial());

  init() async {
    if (state is SwapLoaded) {
      return;
    }
    emit(SwapLoading(state));
    fetchBalances();
    state.streamController.stream
        .transform(debounce(Duration(milliseconds: 500)))
        .listen((s) async {
      emit(SwapLoaded(state, isInProgress: true));
      if (double.tryParse(s) != null && double.tryParse(s) > 0) {
        state.swapService
            .getAmountsOut(
                state.fromToken.getTokenName(), state.toToken.getTokenName(), s)
            .then((value) {
          state.toFieldController.text = EthereumService.formatDouble(value);
        });
      } else {
        state.toFieldController.text = "0.0";
      }
      emit(SwapLoaded(state, isInProgress: false));
    });
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

    emit(SwapLoaded(state, fromToken: selectedToken));

    await getAllowances();
    selectedToken.balance = await getTokenBalance(selectedToken);

    emit(SwapLoaded(state, fromToken: selectedToken));
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
    emit(SwapLoaded(state, toToken: selectedToken));
    selectedToken.balance = await getTokenBalance(selectedToken);
    emit(SwapLoaded(state, toToken: selectedToken));
    if (fromTokenChanged) getAllowances();
  }

  approve() async {
    if (!state.isInProgress) {
      emit(TransactionPendingState(state,
          transactionStatus: TransactionStatus(
              "Approve ${state.fromToken.name}",
              Status.PENDING,
              "Transaction Pending")));
      try {
        var res =
            await state.swapService.approve(state.fromToken.getTokenName());
        Stream<TransactionReceipt> result =
            state.swapService.ethService.pollTransactionReceipt(res);
        result.listen((event) {
          state.approved = event.status;
          if (event.status) {
            state.approved = true;
            emit(TransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    "Approve ${state.fromToken.name}",
                    Status.SUCCESSFUL,
                    "Transaction Successfull",
                    res)));
          } else {
            emit(TransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    "Approve ${state.fromToken.name}",
                    Status.FAILED,
                    "Transaction Failed",
                    res)));
          }
        });
      } on Exception catch (value) {
        state.approved = false;
        emit(TransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Approve ${state.fromToken.name}",
                Status.FAILED,
                "Transaction Failed")));
      }
    }
  }

  Future swapTokens(Gas gas) async {
    if (state.approved && !state.isInProgress) {
      if (gas != null) {
        emit(TransactionPendingState(state,
            transactionStatus: TransactionStatus(
                "Swap ${state.toFieldController.text} ${state.toToken.getTokenName()} for ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                Status.PENDING,
                "Transaction Pending")));
        try {
          var res = await state.swapService.swapTokens(
              state.fromToken.getTokenName(),
              state.toToken.getTokenName(),
              state.fromFieldController.text,
              ((1 - getSlippage()) * double.parse(state.toFieldController.text))
                  .toString(),
              gas);
          Stream<TransactionReceipt> result =
              state.swapService.ethService.pollTransactionReceipt(res);
          result.listen((event) async {
            if (event.status) {
              String fromBalance = await getTokenBalance(state.fromToken);
              String toBalance = await getTokenBalance(state.toToken);
              Token from = state.fromToken;
              Token to = state.toToken;
              from.balance = fromBalance;
              to.balance = toBalance;
              state.fromToken = from;
              state.toToken = to;
              emit(TransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Swapped ${state.toFieldController.text} ${state.toToken.getTokenName()} for ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                      Status.SUCCESSFUL,
                      "Transaction Successful",
                      res)));
            } else {
              emit(TransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Not Swapped ${state.toFieldController.text} ${state.toToken.getTokenName()} for ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
                      Status.FAILED,
                      "Transaction Failed",
                      res)));
            }
          });
        } on Exception catch (error) {
          emit(TransactionFinishedState(state,
              transactionStatus: TransactionStatus(
                  "Not Swapped ${state.toFieldController.text} ${state.toToken.getTokenName()} for ${state.fromFieldController.text} ${state.fromToken.getTokenName()}",
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
    Token a = state.fromToken;
    state.fromToken = state.toToken;
    state.toToken = a;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
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
    double b = double.tryParse(state.toFieldController.text) ?? 0;
    if (a != 0 && b != 0) {
      if (state.isPriceRatioForward)
        return EthereumService.formatDouble((a / b).toString(), 5);
      return EthereumService.formatDouble((b / a).toString(), 5);
    }
    return "0.0";
  }

  addListenerToFromField() {
    if (!state.fromFieldController.hasListeners) {
      state.fromFieldController.addListener(() {
        listenInput();
      });
    }
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

  Future computePriceImpact() async {
    try {
      double x = double.parse(await state.swapService.getAmountsOut(
          state.fromToken.getTokenName(), state.toToken.getTokenName(), "0.1"));
      double r = 0.1;
      double input = double.tryParse(state.fromFieldController.text) ?? 0;
      double y = double.tryParse(state.toFieldController.text) ?? 0;

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
    if (state.fromToken.getAllowances() >= EthereumService.getWei(input)) {
      state.streamController.add(input);
      emit(SwapLoaded(state, approved: true));
    } else {
      state.streamController.add(input);
      emit(SwapLoaded(state, approved: false));
    }
  }

  makeTransaction() async {
    Transaction transaction = await state.swapService.makeSwapTransaction(
        state.fromToken.getTokenName(),
        state.toToken.getTokenName(),
        state.fromFieldController.text,
        ((1 - getSlippage()) * double.parse(state.toFieldController.text))
            .toString());
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
      r.add(EthereumService.addressToTokenMap[addr.toLowerCase()]);
    });
    return r;
  }

  void closeToast() {
    if (state is TransactionPendingState)
      emit(TransactionPendingState(state, showingToast: false));
    else if (state is TransactionFinishedState)
      emit(TransactionFinishedState(state, showingToast: false));
  }
}
