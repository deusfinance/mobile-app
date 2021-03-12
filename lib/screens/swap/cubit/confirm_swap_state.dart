//TODO (@kazem)
// import 'package:deus_mobile/models/GWei.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/cupertino.dart';
//
// import 'confirm_swap_cubit.dart';
//
// abstract class ConfirmSwapState extends Equatable {
//   GasFee gasFee;
//   int estimatedGasNumber;
//   GWei gWei;
//   double ethPrice;
//
//   ConfirmSwapState() {
//     gasFee = GasFee.AVERAGE;
//   }
//
//   ConfirmSwapState.copy(ConfirmSwapState state)
//       : this.gasFee = state.gasFee,
//         this.estimatedGasNumber = state.estimatedGasNumber,
//         this.gWei = state.gWei,
//         this.ethPrice = state.ethPrice;
//
//   @override
//   List<Object> get props => [estimatedGasNumber, gasFee, gWei, ethPrice];
// }
//
// class ConfirmSwapInitial extends ConfirmSwapState {
//   ConfirmSwapInitial() : super();
// }
//
// class ConfirmSwapLoading extends ConfirmSwapState {
//   ConfirmSwapLoading() : super();
// }
//
// class ConfirmSwapConfirm extends ConfirmSwapState {
//   ConfirmSwapConfirm(ConfirmSwapState state, {int estimatedGasNumber, GWei gWei, double ethPrice})
//       : super.copy(state) {
//     if(estimatedGasNumber!=null)
//       this.estimatedGasNumber = estimatedGasNumber;
//     if(gWei!=null)this.gWei = gWei;
//     if(ethPrice!=null)this.ethPrice = ethPrice;
//   }
// }
//
// class ConfirmSwapBasic extends ConfirmSwapState {
//   ConfirmSwapBasic(ConfirmSwapState state, {int estimatedGasNumber, GWei gWei, double ethPrice})
//       : super.copy(state) {
//     if(estimatedGasNumber!=null)
//       this.estimatedGasNumber = estimatedGasNumber;
//     if(gWei!=null)this.gWei = gWei;
//     if(ethPrice!=null)this.ethPrice = ethPrice;
//   }
// }
//
// class ConfirmSwapAdvanced extends ConfirmSwapState {
//   TextEditingController nonceController;
//   TextEditingController gasLimitController;
//   TextEditingController gWeiController;
//
//   ConfirmSwapAdvanced(ConfirmSwapState state) : super.copy(state) {
//     nonceController = new TextEditingController();
//     gasLimitController = new TextEditingController();
//     gWeiController = new TextEditingController();
//   }
// }
