import 'dart:ui';

import 'package:deus_mobile/core/widgets/default_screen/back_button.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/stake_and_lock/cross_fade_duo_button.dart';
import 'package:deus_mobile/core/widgets/dark_button.dart';
// import 'package:deus_mobile/core/widgets/header_with_address.dart';
import 'package:deus_mobile/core/widgets/stake_and_lock/steps.dart';
import 'package:deus_mobile/core/widgets/text_field_with_max.dart';
import 'package:deus_mobile/core/widgets/toast.dart';
import 'package:deus_mobile/core/widgets/default_screen/bottom_nav_bar.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/confirm_gas/confirm_gas.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_state.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3dart/web3dart.dart';
import 'cubit/stake_cubit.dart';

class StakeScreen extends StatefulWidget {
  static const url = '/stake';

  const StakeScreen();

  @override
  _StakeScreenState createState() => _StakeScreenState();
}

class _StakeScreenState extends State<StakeScreen> {
  final gradient = MyColors.blueToGreenGradient;
  static const kSpacer = SizedBox(height: 20);
  static const kMediumSpacer = SizedBox(height: 15);
  static const kSmallSpacer = SizedBox(height: 12);

  @override
  void initState() {
    context.read<StakeCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      child: SafeArea(
        child: BlocBuilder<StakeCubit, StakeState>(builder: (_, state) {
          if (state is StakeLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            context.read<StakeCubit>().addListenerToFromField();
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height + 50,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kSpacer,
                        Text(
                          'Stake your ${state.stakeTokenObject.stakeToken.name}',
                          style: TextStyle(fontSize: 25),
                        ),
                        kSmallSpacer,
                        Text(
                          '${state.stakeTokenObject.apy}% APY',
                          style: TextStyle(fontSize: 20),
                        ),
                        kSpacer,
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'Balance: ${state.balance}',
                            style: MyStyles.lightWhiteSmallTextStyle,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextFieldWithMax(
                          controller: state.fieldController,
                          maxValue: state.balance,
                        ),
                        kSmallSpacer,
                        DarkButton(
                          label: 'Show me the contract',
                          onPressed: () {},
                          labelStyle: MyStyles.whiteMediumTextStyle,
                        ),
                        kSmallSpacer,
                        _buildStakeApproveButton(state),
                        kMediumSpacer,
                        if (state is StakeHasToApprove || state is StakePendingApprove) Steps(),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                _buildToastWidget(state),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildTransactionPending(TransactionStatus transactionStatus) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGrey,
        onPressed: () {

        },
        onClosed: () {
          context.read<StakeCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionSuccessFul(TransactionStatus transactionStatus) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGreen,
        onPressed: () {
        },
        onClosed: () {
          context.read<StakeCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionFailed(TransactionStatus transactionStatus) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastRed,
        onPressed: () {
        },
        onClosed: () {
          context.read<StakeCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildToastWidget(StakeState state) {
    if(state.showingToast){
      if (state is StakePendingApprove){
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionPending(state.transactionStatus));
      }
      if (state is StakePendingStake){
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionPending(state.transactionStatus));
      }
      if (state is StakeHasToApprove){
        if (state.transactionStatus.status == Status.PENDING) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: _buildTransactionPending(state.transactionStatus));
        } else if (state.transactionStatus.status == Status.SUCCESSFUL) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: _buildTransactionSuccessFul(state.transactionStatus));
        } else if (state.transactionStatus.status == Status.FAILED) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: _buildTransactionFailed(state.transactionStatus));
        }
      }
      if (state is StakeIsApproved){
        if (state.transactionStatus.status == Status.PENDING) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: _buildTransactionPending(state.transactionStatus));
        } else if (state.transactionStatus.status == Status.SUCCESSFUL) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: _buildTransactionSuccessFul(state.transactionStatus));
        } else if (state.transactionStatus.status == Status.FAILED) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: _buildTransactionFailed(state.transactionStatus));
        }
      }
    }
    return Container();
  }

  Future<Gas> showConfirmGasFeeDialog(Transaction transaction) async {
    Gas res = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
          alignment: Alignment.center,
          child: ConfirmGasScreen(
            transaction: transaction,
          )),
      barrierDismissible: true,
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          child: child,
          opacity: anim1,
        ),
      ),
      transitionDuration: Duration(milliseconds: 10),
    );
    return res;
  }


  Widget _buildStakeApproveButton(StakeState state) {
    // if (state.fieldController.text == "" ||
    //     (double.tryParse(state.fieldController.text) != null &&
    //         double.tryParse(state.fieldController.text) == 0)) {
    //   return Container(
    //     width: MediaQuery.of(context).size.width,
    //     padding: EdgeInsets.all(16.0),
    //     decoration: MyStyles.darkWithNoBorderDecoration,
    //     child: Align(
    //       alignment: Alignment.center,
    //       child: Text(
    //         "ENTER AN AMOUNT",
    //         style: MyStyles.lightWhiteMediumTextStyle,
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //   );
    // }

    // else if (state.balance <
    //     double.parse(
    //         state.fieldController.text)) {
    //   return Container(
    //     width: MediaQuery.of(context).size.width,
    //     padding: EdgeInsets.all(16.0),
    //     decoration: MyStyles.darkWithNoBorderDecoration,
    //     child: Align(
    //       alignment: Alignment.center,
    //       child: Text(
    //         "INSUFFICIENT BALANCE",
    //         style: MyStyles.lightWhiteMediumTextStyle,
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //   );
    // }
    return CrossFadeDuoButton(
      gradientButtonLabel: 'APPROVE',
      mergedButtonLabel: 'Stake',
      offButtonLabel: 'Stake',
      showBothButtons: state is StakeHasToApprove || state is StakePendingApprove,
      showLoading: state is StakePendingApprove || state is StakePendingStake,
      onPressed: () async {
        if (state is StakePendingApprove || state is StakePendingStake) return;
        if (state is StakeIsApproved) {
          Transaction transaction = await context.read<StakeCubit>().makeTransaction();
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          if(transaction!=null) {
            Gas gas = await showConfirmGasFeeDialog(transaction);
            context.read<StakeCubit>().stake(gas);
          }
        }
        if (state is StakeHasToApprove) {
          Transaction transaction = await context.read<StakeCubit>().makeApproveTransaction();
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          if(transaction!=null) {
            Gas gas = await showConfirmGasFeeDialog(transaction);
            context.read<StakeCubit>().approve(gas);
          }
        }
      },
    );
  }
}
