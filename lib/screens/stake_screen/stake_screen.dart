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

enum StakeStates { hasToApprove, pendingApproveDividedButton, isApproved, pendingApproveMergedButton }

class StakeScreen extends StatefulWidget {
  static const url = '/stake';

  const StakeScreen();

  @override
  _StakeScreenState createState() => _StakeScreenState();
}

class _StakeScreenState extends State<StakeScreen> {
  final String address = '0x3a6dabD6B5C75291a3258C29B418f5805792a87e';

  final double apy = 99.93;

  final balance = 13.234;

  final gradient = MyColors.blueToGreenGradient;

  StakeStates _stakeState = StakeStates.hasToApprove;
  bool _showToast = false;

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
            height: MediaQuery.of(context).size.height - 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kSpacer,
                BackButtonWithText(),
                kSpacer,
                Text(
                  'Stake your sDEA',
                  style: TextStyle(fontSize: 25),
                ),
                kSmallSpacer,
                Text(
                  '$apy% APY',
                  style: TextStyle(fontSize: 20),
                ),
                kSpacer,
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Balance: $balance',
                    style: MyStyles.lightWhiteSmallTextStyle,
                  ),
                ),
                SizedBox(height: 5),
                TextFieldWithMax(
                  controller: _textController,
                  maxValue: balance,
                ),
                kSmallSpacer,
                DarkButton(
                  label: 'Show me the contract',
                  onPressed: () {},
                  labelStyle: MyStyles.whiteMediumTextStyle,
                ),
                kSmallSpacer,
                _buildStakeApproveButton(),
                kMediumSpacer,
                if (_stakeState == StakeStates.hasToApprove) Steps(),
                Spacer(),
                if ((_stakeState != StakeStates.hasToApprove && _showToast) ||
                    (_stakeState == StakeStates.pendingApproveDividedButton && _showToast))
                  _buildToast()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToast() {
    if (_stakeState != StakeStates.pendingApproveDividedButton &&
        _stakeState != StakeStates.pendingApproveMergedButton) {
      return _buildTransactionSuccessToast();
    } else {
      print(_stakeState);
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
        setState(() {
          _showToast = false;
        });
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
        setState(() {
          _showToast = false;
        });
      },
    );
  }

  Widget _buildStakeApproveButton() {
    return CrossFadeDuoButton(
      gradientButtonLabel: 'APPROVE',
      mergedButtonLabel: 'Stake',
      offButtonLabel: 'Stake',
      showBothButtons:
          _stakeState == StakeStates.hasToApprove || _stakeState == StakeStates.pendingApproveDividedButton,
      showLoading: _stakeState == StakeStates.pendingApproveDividedButton ||
          _stakeState == StakeStates.pendingApproveMergedButton,
      onPressed: () async {
        if (_stakeState == StakeStates.isApproved || _stakeState == StakeStates.pendingApproveMergedButton) {
          setState(() {
            _showToast = true;
            _stakeState = StakeStates.pendingApproveMergedButton;
          });
          await Future.delayed(Duration(seconds: 3));
          setState(() {
            if (!_showToast) {
              _showToast = true;
            }
            _stakeState = StakeStates.isApproved;
          });
        } else {
          setState(() {
            _stakeState = StakeStates.pendingApproveDividedButton;
            _showToast = true;
          });
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            if (!_showToast) {
              _showToast = true;
            }
            _stakeState = StakeStates.isApproved;
          });
        }
      },
    );
  }
}
