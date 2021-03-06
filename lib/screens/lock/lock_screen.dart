import 'dart:ui';

import 'package:deus/core/widgets/back_button.dart';
import 'package:deus/core/widgets/cross_fade_duo_button.dart';
import 'package:deus/core/widgets/dark_button.dart';
import 'package:deus/core/widgets/filled_gradient_selection_button.dart';
import 'package:deus/core/widgets/header_with_address.dart';
import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/core/widgets/steps.dart';
import 'package:deus/core/widgets/text_field_with_max.dart';
import 'package:deus/core/widgets/toast.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

enum LockScreenStates {
  hasToApprove,
  pendingApproveDividedButton,
  isApproved,
  pendingApproveMergedButton
}

class LockScreen extends StatefulWidget {
  static const url = '/Lock';

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final String address = '0x3a6dabD6B5C75291a3258C29B418f5805792a87e';

  final balance = 13.234;

  final gradient = MyColors.blueToGreenGradient;

  LockScreenStates _lockState = LockScreenStates.hasToApprove;
  bool _showToast = false;

  final _textController = TextEditingController();
                                                //Date Format: year, month, day, hour, minute, seconds
  int endTime = DateTime.now().millisecondsSinceEpoch + DateTime(2021, 5,3, 10, 0, 0).difference(DateTime.now()).inMilliseconds; // Time until countDown ends

  static const kBigSpacer = SizedBox(height: 20);
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
            height: MediaQuery.of(context).size.height + 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderWithAddress(
                  walletAddress: address,
                ),
                kBigSpacer,
                BackButtonWithText(),
                kBigSpacer,
                Text(
                  'Lock your DEA',
                  style: TextStyle(fontSize: 25),
                ),
                kBigSpacer,
                Text(
                  'If you lock your DEA you will mint sDEA which can be used for single asset staking or for liquidity pools.',
                  style: MyStyles.whiteMediumTextStyle,
                ),
                _buildCountDownTimer(),
                kSmallSpacer,
                Text(
                  'You will also receive TIME tokens that can be used for single asset staking. Read more about the use of TIME token on our wiki',
                  style: MyStyles.whiteMediumTextStyle,
                ), //TODO: add link
                kBigSpacer,
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
                _buildLockApproveButton(),
                kMediumSpacer,
                if (_lockState == LockScreenStates.hasToApprove) Steps(),
                Spacer(),
                if ((_lockState != LockScreenStates.hasToApprove && _showToast) ||
                    (_lockState == LockScreenStates.pendingApproveDividedButton &&
                        _showToast))
                  _buildToast()
              ],
            ),
          ),
        ),
      ),
    );
  }

  CountdownTimer _buildCountDownTimer() {
    return CountdownTimer(
      endTime: endTime,
      widgetBuilder: (_, time) {
        if (time == null) {
          return Text(
              'Current locking period still lasts 0 Days, 0 Hours, 0 Minutes and 0 Seconds.',
              style: MyStyles.gradientMediumTextStyle);
        } else {
          return Text(
            'Current locking period still lasts ${time?.days ?? 0} Days, ${time?.hours ?? 0} Hours, ${time?.min ?? 0} Minutes and ${time?.sec ?? 0} Seconds.',
            style: MyStyles.gradientMediumTextStyle,
          );
        }
      },
    );
  }

  Widget _buildToast() {
    if (_lockState != LockScreenStates.pendingApproveDividedButton &&
        _lockState != LockScreenStates.pendingApproveMergedButton) {
      return _buildTransactionSuccessToast();
    } else {
      return _buildTransactionPending();
    }
  }

  Toast _buildTransactionSuccessToast() {
    return Toast(
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



  Widget _buildLockApproveButton() {
    return CrossFadeDuoButton(
      gradientButtonLabel: 'APPROVE',
      mergedButtonLabel: 'LOCK',
      offButtonLabel: 'LOCK',
      showBothButtons: _lockState == LockScreenStates.hasToApprove ||
          _lockState == LockScreenStates.pendingApproveDividedButton,
      showLoading: _lockState == LockScreenStates.pendingApproveDividedButton ||
          _lockState == LockScreenStates.pendingApproveMergedButton,
      onPressed: () async {
        if (_lockState == LockScreenStates.isApproved ||
            _lockState == LockScreenStates.pendingApproveMergedButton) {
          setState(() {
            _showToast = true;
            _lockState = LockScreenStates.pendingApproveMergedButton;
          });
          await Future.delayed(Duration(seconds: 3));
          setState(() {
            if (!_showToast) {
              _showToast = true;
            }
            _lockState = LockScreenStates.isApproved;
          });
        } else {
          setState(() {
            _lockState = LockScreenStates.pendingApproveDividedButton;
            _showToast = true;
          });
          await Future.delayed(Duration(seconds: 3));
          setState(() {
            if (!_showToast) {
              _showToast = true;
            }
            _lockState = LockScreenStates.isApproved;
          });
        }
      },
    );
  }
}
