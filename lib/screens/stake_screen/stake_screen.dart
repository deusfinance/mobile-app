import 'dart:ui';

import 'package:deus/core/widgets/back_button.dart';
import 'package:deus/core/widgets/cross_fade_duo_button.dart';
import 'package:deus/core/widgets/dark_button.dart';
import 'package:deus/core/widgets/header_with_address.dart';
import 'package:deus/core/widgets/steps.dart';
import 'package:deus/core/widgets/text_field_with_max.dart';
import 'package:deus/core/widgets/toast.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

enum ButtonStates {
  hasToApprove,
  pendingApproveDividedButton,
  isApproved,
  pendingApproveMergedButton
}

class StakeScreen extends StatefulWidget {
  static const url = '/stake';

  @override
  _StakeScreenState createState() => _StakeScreenState();
}

class _StakeScreenState extends State<StakeScreen> {
  final String address = '0x3a6dabD6B5C75291a3258C29B418f5805792a87e';

  final double apy = 99.93;

  final balance = 13.234;

  final gradient = MyColors.blueToGreenGradient;

  ButtonStates _stakeState = ButtonStates.hasToApprove;
  bool _showToast = false;

  final _textController = TextEditingController();

  static const kSpacer = SizedBox(height: 20);
  static const kMediumSpacer = SizedBox(height: 15);
  static const kSmallSpacer = SizedBox(height: 12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColors.Background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderWithAddress(
                  walletAddress: address,
                ),
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
                if (_stakeState == ButtonStates.hasToApprove) Steps(),
                Spacer(),
                if ((_stakeState != ButtonStates.hasToApprove && _showToast) ||
                    (_stakeState == ButtonStates.pendingApproveDividedButton &&
                        _showToast))
                  _buildToast()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToast() {
    if (_stakeState != ButtonStates.pendingApproveDividedButton &&
        _stakeState != ButtonStates.pendingApproveMergedButton) {
      return _buildTransactionSuccessToast();
    } else {
      print(_stakeState);
      return _buildTransactionPending();
    }
  }

  Toast _buildTransactionSuccessToast() {
    return Toast(
      label: 'Successful',
      color: Color(MyColors.ToastGreen),
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
      label: 'Transaction Pending',
      color: Color(MyColors.ToastGrey),
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
      showBothButtons: _stakeState == ButtonStates.hasToApprove ||
          _stakeState == ButtonStates.pendingApproveDividedButton,
      showLoading: _stakeState == ButtonStates.pendingApproveDividedButton ||
          _stakeState == ButtonStates.pendingApproveMergedButton,
      onPressed: () async {
        if (_stakeState == ButtonStates.isApproved ||
            _stakeState == ButtonStates.pendingApproveMergedButton) {
          setState(() {
            _showToast = true;
            _stakeState = ButtonStates.pendingApproveMergedButton;
          });
          await Future.delayed(Duration(seconds: 3));
          setState(() {
            if (!_showToast) {
              _showToast = true;
            }
            _stakeState = ButtonStates.isApproved;
          });
        } else {
          setState(() {
            _stakeState = ButtonStates.pendingApproveDividedButton;
            _showToast = true;
          });
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            if (!_showToast) {
              _showToast = true;
            }
            _stakeState = ButtonStates.isApproved;
          });
        }
      },
    );
  }
}
