
import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/data_source/stock_data.dart';
import 'package:deus_mobile/data_source/xdai_stock_data.dart';
import 'package:deus_mobile/models/synthetics/stock_address.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_state.dart';
import 'package:stream_transform/stream_transform.dart';

class XDaiSyntheticsCubit extends Cubit<XDaiSyntheticsState>{

  XDaiSyntheticsCubit() : super(XDaiSyntheticsInitialState());


  init() async{
    emit(XDaiSyntheticsLoadingState(state));
    //TODO check market closed
    bool res1 = await XDaiStockData.getData();
    bool res2 = await XDaiStockData.getStockAddresses();
    if(res1 && res2) {
      getTokenBalance(state.fromToken);
      state.streamController.stream
          .transform(debounce(Duration(milliseconds: 500)))
          .listen((s) async {
        if(state is XDaiSyntheticsAssetSelectedState){
          emit(XDaiSyntheticsAssetSelectedState(state, isInProgress: true));
          if (double.tryParse(s) != null && double.tryParse(s) > 0) {
              //TODO get price
              String value = "00";
              state.toFieldController.text = EthereumService.formatDouble(value);
          } else {
            state.toFieldController.text = "0.0";
          }
          emit(XDaiSyntheticsAssetSelectedState(state, isInProgress: false));
        }
      });
    }else{
      emit(XDaiSyntheticsErrorState(state));
    }
  }

  getTokenBalance(Token token) async {
    String tokenAddress;
    if(token.getTokenName() == "xdai"){
      tokenAddress = "0x0000000000000000000000000000000000000001";
    }else{
      StockAddress stockAddress = XDaiStockData.getStockAddress(token);
      if(state.mode == Mode.LONG){
        tokenAddress = stockAddress.long;
      }else if(state.mode == Mode.SHORT){
        tokenAddress = stockAddress.short;
      }
    }
    token.balance = await state.service.getTokenBalance(tokenAddress);
  }

  Future getAllowances() async {
    emit(XDaiSyntheticsAssetSelectedState(state, approved: false, isInProgress: true));
    String tokenAddress;
    if(state.fromToken.getTokenName() == "xdai"){
      tokenAddress = "0x0000000000000000000000000000000000000001";
    }else{
      StockAddress stockAddress = XDaiStockData.getStockAddress(state.fromToken);
      if(state.mode == Mode.LONG){
        tokenAddress = stockAddress.long;
      }else if(state.mode == Mode.SHORT){
        tokenAddress = stockAddress.short;
      }
    }
    state.fromToken.allowances = await state.service.getAllowances(tokenAddress);
    if (state.fromToken.getAllowances() > BigInt.zero)
      emit(XDaiSyntheticsAssetSelectedState(state, approved: true, isInProgress: false));
    else
      emit(XDaiSyntheticsAssetSelectedState(state, approved: false, isInProgress: false));
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

  fromTokenChanged(Token selectedToken) async {
    state.toToken = CurrencyData.xdai;
    state.fromToken = selectedToken;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";

    emit(XDaiSyntheticsAssetSelectedState(state, fromToken: selectedToken));

    await getAllowances();
    selectedToken.balance = await getTokenBalance(selectedToken);

    emit(XDaiSyntheticsAssetSelectedState(state, fromToken: selectedToken));
  }

  toTokenChanged(Token selectedToken) async {
    state.fromToken = CurrencyData.xdai;
    state.toToken = selectedToken;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";

    emit(XDaiSyntheticsAssetSelectedState(state, toToken: selectedToken));

    await getAllowances();
    selectedToken.balance = await getTokenBalance(selectedToken);

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
    String input = state.fromFieldController.text;
    if (input == null || input.isEmpty) {
      input = "0.0";
    }
    if (state.fromToken.getAllowances() >= EthereumService.getWei(input, state.fromToken.getTokenName())) {
      state.streamController.add(input);
      emit(XDaiSyntheticsAssetSelectedState(state, approved: true));
    } else {
      state.streamController.add(input);
      emit(XDaiSyntheticsAssetSelectedState(state, approved: false));
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
    emit(XDaiSyntheticsAssetSelectedState(state, isPriceRatioForward: !state.isPriceRatioForward));
  }

  void setMode(Mode mode) {
    if(state is XDaiSyntheticsAssetSelectedState)
      emit(XDaiSyntheticsAssetSelectedState(state, mode:mode));
  }

  void closeToast() {
    if (state is XDaiSyntheticsTransactionPendingState)
      emit(XDaiSyntheticsTransactionPendingState(state, showingToast: false));
    else if (state is XDaiSyntheticsTransactionFinishedState)
      emit(XDaiSyntheticsTransactionFinishedState(state, showingToast: false));
  }

// Future approve() async {
  //   if (!isInProgress) {
  //     setState(() {
  //       isInProgress = true;
  //     });
  //     showToast(
  //         context,
  //         TransactionStatus(
  //             "Approve ${syntheticModel.from.name}", Status.PENDING, "Pending"));
  //
  //     var res = await stockService.approve(syntheticModel.from.getTokenName());
  //     Stream<TransactionReceipt> result =
  //     stockService.ethService.pollTransactionReceipt(res);
  //     result.listen((event) {
  //       setState(() {
  //         isInProgress = false;
  //         syntheticModel.approved = event.status;
  //       });
  //       if (event.status) {
  //         showToast(
  //             context,
  //             TransactionStatus("Approved ${syntheticModel.from.name}",
  //                 Status.SUCCESSFUL, "Successful"));
  //       } else {
  //         showToast(
  //             context,
  //             TransactionStatus("Approve of ${syntheticModel.from.name}",
  //                 Status.FAILED, "Failed"));
  //       }
  //     });
  //   }
  // }
  //
  // Future sell() async {
  //   if (!isInProgress) {
  //     setState(() {
  //       isInProgress = true;
  //     });
  //     String tokenAddress;
  //     if(syntheticModel.from.getTokenName() == "dai"){
  //       tokenAddress = await stockService.ethService.getTokenAddrHex("dai", "token");
  //     }else{
  //       StockAddress stockAddress = StockData.getStockAddress(syntheticModel.from);
  //       tokenAddress = syntheticModel.selectionMode == SelectionMode.long? stockAddress.long: stockAddress.short;
  //     }
  //     var res = await stockService.sell(tokenAddress, fromFieldController.text, null);
  //     Stream<TransactionReceipt> result =
  //     stockService.ethService.pollTransactionReceipt(res);
  //     result.listen((event) {
  //       setState(() {
  //         isInProgress = false;
  //         syntheticModel.approved = event.status;
  //       });
  //       if (event.status) {
  //         showToast(
  //             context,
  //             TransactionStatus("Sell ${syntheticModel.from.name}",
  //                 Status.SUCCESSFUL, "Failed"));
  //       } else {
  //         showToast(
  //             context,
  //             TransactionStatus("Sell of ${syntheticModel.from.name}",
  //                 Status.FAILED, "Failed"));
  //       }
  //     });
  //   }
  // }
  //
  // Future buy() async {
  //   if (!isInProgress) {
  //     setState(() {
  //       isInProgress = true;
  //     });
  //     String tokenAddress;
  //     if(syntheticModel.from.getTokenName() == "dai"){
  //       tokenAddress = await stockService.ethService.getTokenAddrHex("dai", "token");
  //     }else{
  //       StockAddress stockAddress = StockData.getStockAddress(syntheticModel.from);
  //       tokenAddress = syntheticModel.selectionMode == SelectionMode.long? stockAddress.long: stockAddress.short;
  //     }
  //
  //     var res = await stockService.buy(tokenAddress, fromFieldController.text, null);
  //     Stream<TransactionReceipt> result =
  //     stockService.ethService.pollTransactionReceipt(res);
  //     result.listen((event) {
  //       setState(() {
  //         isInProgress = false;
  //         syntheticModel.approved = event.status;
  //       });
  //       if (event.status) {
  //         showToast(
  //             context,
  //             TransactionStatus("Buy ${syntheticModel.from.name}",
  //                 Status.SUCCESSFUL, "Successful"));
  //       } else {
  //         showToast(
  //             context,
  //             TransactionStatus("Buy of ${syntheticModel.from.name}",
  //                 Status.FAILED, "Failed"));
  //       }
  //     });
  //   }
  // }
}
