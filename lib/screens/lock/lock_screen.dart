// import 'dart:ui';
//
// import '../../core/widgets/default_screen/back_button.dart';
// import '../../core/widgets/default_screen/default_screen.dart';
// import '../../core/widgets/stake_and_lock/cross_fade_duo_button.dart';
// import '../../core/widgets/dark_button.dart';
// import '../../core/widgets/filled_gradient_selection_button.dart';
//
// // import 'package:deus_mobile/core/widgets/header_with_address.dart';
// import '../../core/widgets/selection_button.dart';
// import '../../core/widgets/stake_and_lock/steps.dart';
// import '../../core/widgets/text_field_with_max.dart';
// import '../../core/widgets/toast.dart';
// import '../../models/swap/gas.dart';
// import '../../models/transaction_status.dart';
// import '../confirm_gas/confirm_gas.dart';
// import '../../statics/my_colors.dart';
// import '../../statics/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
// import 'package:web3dart/web3dart.dart';
//
// import 'cubit/lock_cubit.dart';
//
// class LockScreen extends StatefulWidget {
//   static const url = '/Lock';
//
//   const LockScreen();
//
//   @override
//   _LockScreenState createState() => _LockScreenState();
// }
//
// class _LockScreenState extends State<LockScreen> {
//   final gradient = MyColors.blueToGreenGradient;
//
//   //Date Format: year, month, day, hour, minute, seconds
//   int endTime = DateTime.now().millisecondsSinceEpoch +
//       DateTime(2021, 5, 3, 10, 0, 0)
//           .difference(DateTime.now())
//           .inMilliseconds; // Time until countDown ends
//
//   static const kBigSpacer = SizedBox(height: 20);
//   static const kMediumSpacer = SizedBox(height: 15);
//   static const kSmallSpacer = SizedBox(height: 12);
//
//   @override
//   void initState() {
//     context.read<LockCubit>().init();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultScreen(
//       child: SafeArea(
//         child: BlocBuilder<LockCubit, LockState>(builder: (_, state) {
//           if (state is LockLoading) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else {
//             context.read<LockCubit>().addListenerToFromField();
//             return Stack(
//               children: [
//                 SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height + 50,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         kSmallSpacer,
//                         Text(
//                           'Lock your ${state.stakeTokenObject.lockToken.name}',
//                           style: TextStyle(fontSize: 25),
//                         ),
//                         kBigSpacer,
//                         Text(
//                           'If you lock your ${state.stakeTokenObject.lockToken.name} you will mint ${state.stakeTokenObject.stakeToken.name} which can be used for single asset staking or for liquidity pools.',
//                           style: MyStyles.whiteMediumTextStyle,
//                         ),
//                         _buildCountDownTimer(),
//                         kSmallSpacer,
//                         Text(
//                           'You will also receive TIME tokens that can be used for single asset staking. Read more about the use of TIME token on our wiki',
//                           style: MyStyles.whiteMediumTextStyle,
//                         ), //TODO: add link
//                         kBigSpacer,
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             'Balance: ${state.balance}',
//                             style: MyStyles.lightWhiteSmallTextStyle,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         TextFieldWithMax(
//                           controller: state.fieldController,
//                           maxValue: state.balance,
//                         ),
//                         kSmallSpacer,
//                         DarkButton(
//                           label: 'Show me the contract',
//                           onPressed: () {},
//                           labelStyle: MyStyles.whiteMediumTextStyle,
//                         ),
//                         kSmallSpacer,
//                         _buildLockApproveButton(state),
//                         kMediumSpacer,
//                         if (state is LockHasToApprove ||
//                             state is LockPendingApprove)
//                           Steps(),
//                         Spacer(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 _buildToastWidget(state),
//               ],
//             );
//           }
//         }),
//       ),
//     );
//   }
//
//   Widget _buildTransactionPending(TransactionStatus transactionStatus) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Toast(
//         label: transactionStatus.label,
//         message: transactionStatus.message,
//         color: MyColors.ToastGrey,
//         onPressed: () {},
//         onClosed: () {
//           context.read<LockCubit>().closeToast();
//         },
//       ),
//     );
//   }
//
//   Widget _buildTransactionSuccessFul(TransactionStatus transactionStatus) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Toast(
//         label: transactionStatus.label,
//         message: transactionStatus.message,
//         color: MyColors.ToastGreen,
//         onPressed: () {},
//         onClosed: () {
//           context.read<LockCubit>().closeToast();
//         },
//       ),
//     );
//   }
//
//   Widget _buildTransactionFailed(TransactionStatus transactionStatus) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Toast(
//         label: transactionStatus.label,
//         message: transactionStatus.message,
//         color: MyColors.ToastRed,
//         onPressed: () {},
//         onClosed: () {
//           context.read<LockCubit>().closeToast();
//         },
//       ),
//     );
//   }
//
//   Widget _buildToastWidget(LockState state) {
//     if (state.showingToast) {
//       if (state is LockPendingApprove) {
//         return Align(
//             alignment: Alignment.bottomCenter,
//             child: _buildTransactionPending(state.transactionStatus));
//       }
//       if (state is LockPendingLock) {
//         return Align(
//             alignment: Alignment.bottomCenter,
//             child: _buildTransactionPending(state.transactionStatus));
//       }
//       if (state is LockHasToApprove) {
//         if (state.transactionStatus.status == Status.PENDING) {
//           return Align(
//               alignment: Alignment.bottomCenter,
//               child: _buildTransactionPending(state.transactionStatus));
//         } else if (state.transactionStatus.status == Status.SUCCESSFUL) {
//           return Align(
//               alignment: Alignment.bottomCenter,
//               child: _buildTransactionSuccessFul(state.transactionStatus));
//         } else if (state.transactionStatus.status == Status.FAILED) {
//           return Align(
//               alignment: Alignment.bottomCenter,
//               child: _buildTransactionFailed(state.transactionStatus));
//         }
//       }
//       if (state is LockIsApproved) {
//         if (state.transactionStatus.status == Status.PENDING) {
//           return Align(
//               alignment: Alignment.bottomCenter,
//               child: _buildTransactionPending(state.transactionStatus));
//         } else if (state.transactionStatus.status == Status.SUCCESSFUL) {
//           return Align(
//               alignment: Alignment.bottomCenter,
//               child: _buildTransactionSuccessFul(state.transactionStatus));
//         } else if (state.transactionStatus.status == Status.FAILED) {
//           return Align(
//               alignment: Alignment.bottomCenter,
//               child: _buildTransactionFailed(state.transactionStatus));
//         }
//       }
//     }
//     return Container();
//   }
//
//   CountdownTimer _buildCountDownTimer() {
//     return CountdownTimer(
//       endTime: endTime,
//       widgetBuilder: (_, time) {
//         if (time == null) {
//           return Text(
//               'Current locking period still lasts 0 Days, 0 Hours, 0 Minutes and 0 Seconds.',
//               style: MyStyles.gradientMediumTextStyle);
//         } else {
//           return Text(
//             'Current locking period still lasts ${time.days ?? 0} Days, ${time.hours ?? 0} Hours, ${time.min ?? 0} Minutes and ${time.sec ?? 0} Seconds.',
//             style: MyStyles.gradientMediumTextStyle,
//           );
//         }
//       },
//     );
//   }
//
//   Future<Gas?> showConfirmGasFeeDialog(Transaction transaction) async {
//     final Gas? res = await showGeneralDialog(
//       context: context,
//       barrierColor: Colors.black38,
//       barrierLabel: "Barrier",
//       pageBuilder: (_, __, ___) => Align(
//           alignment: Alignment.center,
//           child: ConfirmGasScreen(
//             transaction: transaction,
//             network: Network.ETH,
//           )),
//       barrierDismissible: true,
//       transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
//         filter:
//             ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
//         child: FadeTransition(
//           child: child,
//           opacity: anim1,
//         ),
//       ),
//       transitionDuration: Duration(milliseconds: 10),
//     );
//     return res;
//   }
//
//   Widget _buildLockApproveButton(LockState state) {
//     return CrossFadeDuoButton(
//       gradientButtonLabel: 'APPROVE',
//       mergedButtonLabel: 'LOCK',
//       offButtonLabel: 'LOCK',
//       showBothButtons: state is LockHasToApprove || state is LockPendingApprove,
//       showLoading: state is LockPendingApprove || state is LockPendingLock,
//       onPressed: () async {
//         if (state is LockPendingApprove || state is LockPendingLock) return;
//         if (state is LockIsApproved) {
//           final Transaction transaction =
//               await context.read<LockCubit>().makeTransaction();
//           WidgetsBinding.instance!.focusManager.primaryFocus?.unfocus();
//           if (transaction != null) {
//             final Gas? gas = await showConfirmGasFeeDialog(transaction);
//             await context.read<LockCubit>().lock(gas!);
//           }
//         }
//         if (state is LockHasToApprove) {
//           final Transaction transaction =
//               await context.read<LockCubit>().makeApproveTransaction();
//           WidgetsBinding.instance!.focusManager.primaryFocus?.unfocus();
//           if (transaction != null) {
//             final Gas? gas = await showConfirmGasFeeDialog(transaction);
//             await context.read<LockCubit>().approve(gas!);
//           }
//         }
//       },
//     );
//   }
// }
