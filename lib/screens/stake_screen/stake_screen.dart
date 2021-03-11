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
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/stake_cubit.dart';

class StakeScreen extends StatefulWidget {
  static const url = '/stake';

  const StakeScreen();

  @override
  _StakeScreenState createState() => _StakeScreenState();
}

class _StakeScreenState extends State<StakeScreen> {
  final gradient = MyColors.blueToGreenGradient;

  final _textController = TextEditingController();

  static const kSpacer = SizedBox(height: 20);
  static const kMediumSpacer = SizedBox(height: 15);
  static const kSmallSpacer = SizedBox(height: 12);

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
            child: BlocBuilder<StakeCubit, StakeState>(
              builder: (_, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kSpacer,
                    Text(
                      'Stake your sDEA',
                      style: TextStyle(fontSize: 25),
                    ),
                    kSmallSpacer,
                    Text(
                      '% APY',
                      style: TextStyle(fontSize: 20),
                    ),
                    kSpacer,
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        'Balance: ',
                        style: MyStyles.lightWhiteSmallTextStyle,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFieldWithMax(
                      controller: _textController,
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
                    if (state is StakeHasToApprove) Steps(),
                    Spacer(),
                    if ((!(state is StakeHasToApprove) && state.showToast) ||
                        (state is StakePendingApproveDividedButton && state.showToast))
                      _buildToast(state),
                    Spacer(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToast(StakeState state) {
    if (!(state is StakePendingApproveDividedButton) && !(state is StakePendingApproveMergedButton)) {
      return _buildTransactionSuccessToast();
    } else {
      print(state);
      return _buildTransactionPending();
    }
  }

  Toast _buildTransactionSuccessToast() {
    return Toast(
      message: 'Transaction completed.',
      label: 'Successful',
      color: MyColors.ToastGreen,
      onPressed: () {},
      onClosed: () {
        context.read<StakeCubit>().closeToast();
      },
    );
  }

  Toast _buildTransactionPending() {
    return Toast(
      message: '',
      label: 'Transaction Pending',
      color: MyColors.ToastGrey,
      onPressed: () {},
      onClosed: () {
        context.read<StakeCubit>().closeToast();
      },
    );
  }

  Widget _buildStakeApproveButton(StakeState state) {
    return CrossFadeDuoButton(
      gradientButtonLabel: 'APPROVE',
      mergedButtonLabel: 'Stake',
      offButtonLabel: 'Stake',
      showBothButtons: state is StakeHasToApprove || state is StakePendingApproveDividedButton,
      showLoading: state is StakePendingApproveDividedButton || state is StakePendingApproveMergedButton,
      onPressed: () async {
        if (state is StakePendingApproveDividedButton || state is StakePendingApproveMergedButton) return;
        if (state is StakeIsApproved) context.read<StakeCubit>().stake();
        if (state is StakeHasToApprove) context.read<StakeCubit>().approve();
      },
    );
  }
}
