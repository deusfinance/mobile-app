// TODO (@kazem)
//
// import 'dart:convert';
//
// import 'package:deus_mobile/models/GWei.dart';
// import 'package:deus_mobile/models/gas.dart';
// import 'package:deus_mobile/screens/swap/cubit/confirm_swap_state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:web3dart/web3dart.dart';
//
// import 'package:http/http.dart' as http;
//
// enum GasFee { SLOW, AVERAGE, FAST, CUSTOM }
// class ConfirmSwapCubit extends Cubit<ConfirmSwapState>{
//   ConfirmSwapCubit() : super(ConfirmSwapInitial());
//
//   init(Transaction transaction) async{
//     emit(ConfirmSwapLoading());
//     int estimatedGasNumber = await estimateGas(transaction);
//     GWei gWei = await getGWei();
//     double ethPrice = await getEthPrice();
//     emit(ConfirmSwapConfirm(state, estimatedGasNumber: estimatedGasNumber, gWei: gWei, ethPrice: ethPrice));
//   }
//
//   Future<int> estimateGas(Transaction transaction) async {
//     Map<String, dynamic> map = new Map();
//     map['from'] = transaction.from;
//     map['to'] = transaction.to;
//     map['data'] = transaction.data;
//     map['value'] = transaction.value;
//     var response = await http.post("https://app.deus.finance/app/estimate", body: json.encode(map));
//     if (response.statusCode == 200) {
//       var js = json.decode(response.body);
//       return js['gas_fee'];
//     } else {
//       return 0;
//     }
//   }
//
//   Future<GWei> getGWei() async {
//     var response =
//     await http.get("https://ethgasstation.info/json/ethgasAPI.json");
//     if (response.statusCode == 200) {
//       var map = json.decode(response.body);
//       return GWei.fromJson(map);
//     } else {
//       return null;
//     }
//   }
//
//   Future<double> getEthPrice() async {
//     var response = await http.get(
//         "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd");
//     if (response.statusCode == 200) {
//       var map = json.decode(response.body);
//       return map['ethereum']['usd'];
//     } else {
//       return null;
//     }
//   }
//
//   computeGasFee({GasFee gFee}) {
//     if (gFee == null) {
//       gFee = state.gasFee;
//     }
//     return state.estimatedGasNumber * computeGasPrice(gFee: gFee);
//   }
//
//   computeGasPrice({GasFee gFee}) {
//     // if (gFee == null) {
//     //   gFee = state.gasFee;
//     // }
//     // if (gFee == GasFee.SLOW) {
//     //   return 0.000000001 * state.gWei.getSlow();
//     // } else if (gFee == GasFee.AVERAGE) {
//     //   return 0.000000001 * state.gWei.getAverage();
//     // } else if (gFee == GasFee.FAST) {
//     //   return 0.000000001 * state.gWei.getFast();
//     // } else if (state is ConfirmSwapAdvanced ) {
//     //   double gw = 0;
//     //   if (state.gWeiController.text != "" &&
//     //       double.tryParse(gWeiController.text) != null) {
//     //     gw = double.tryParse(gWeiController.text);
//     //   }
//     //   return 0.000000001 * gw;
//     // }
//   }
//
//   edit(){
//     emit(ConfirmSwapBasic(state));
//   }
//
//   Gas confirmedGas(){
//     Gas gas = new Gas();
//     gas.gasPrice = computeGasFee();
//     if (state.gasFee == GasFee.CUSTOM) {
//       gas.nonce = int.tryParse(state.nonceController.text) ?? 0;
//       gas.gasLimit = int.tryParse(gasLimitController.text) ?? 0;
//     }
//   }
//
// }
//
