import 'dart:ui';

import 'package:deus/core/widgets/back_button.dart';
import 'package:deus/core/widgets/dark_button.dart';
import 'package:deus/core/widgets/filled_gradient_selection_button.dart';
import 'package:deus/core/widgets/header_with_address.dart';
import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/core/widgets/text_field_with_max.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

enum LockStates {
  hasToApprove,
  pendingApprove,
  canLock,
  lockPendingApprove,
  lockApproved
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

  LockStates _lockState = LockStates.hasToApprove;
  bool _showToast = false;

  final _textController = TextEditingController();

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30; // current Time in the locking period

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
                SizedBox(
                  height: 23,
                ),
                BackButtonWithText(),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Lock your DEA',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'If you lock your DEA you will mint sDEA which can be used for single asset staking or for liquidity pools.',
                  style: MyStyles.whiteMediumTextStyle,
                ),
                CountdownTimer(
                  endTime: endTime,
                  widgetBuilder: (_, time) {
                    if (time == null) {
                      return Text('Current locking period still lasts 0 Days, 0 Hours, 0 Minutes and 0 Seconds.', style: MyStyles.gradientMediumTextStyle);
                    } else {
                      return Text(
                        'Current locking period still lasts ${time.days != null ? time.days : 0} Days, ${time.hours != null ? time.hours : 0} Hours, ${time.min != null ? time.min : 0} Minutes and ${time.sec != null ? time.sec : 0} Seconds.',
                        style: MyStyles.gradientMediumTextStyle,
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'You will also receive TIME tokens that can be used for single asset staking. Read more about the use of TIME token on our wiki',
                  style: MyStyles.whiteMediumTextStyle,
                ), //TODO: add link
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Balance: $balance',
                    style: MyStyles.lightWhiteSmallTextStyle,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextFieldWithMax(
                  controller: _textController,
                  maxValue: balance,
                ),
                SizedBox(
                  height: 12,
                ),
                DarkButton(
                  label: 'Show me the contract',
                  onPressed: () {},
                  labelStyle: MyStyles.whiteMediumTextStyle,
                ),
                SizedBox(
                  height: 12,
                ),
                _buildLockApproveButton(),
                SizedBox(
                  height: 15,
                ),
                if (_lockState == LockStates.hasToApprove) _buildSteps(),
                Spacer(),
                if ((_lockState != LockStates.hasToApprove && _showToast) ||
                    (_lockState == LockStates.lockPendingApprove && _showToast))
                  _buildToast()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildToast() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
          color: _lockState != LockStates.pendingApprove &&
                  _lockState != LockStates.lockPendingApprove
              ? Color(MyColors.ToastGreen)
              : Color(MyColors.ToastGrey)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _lockState != LockStates.pendingApprove &&
                        _lockState != LockStates.lockPendingApprove
                    ? 'Successful'
                    : 'Transaction Pending',
                style: MyStyles.whiteMediumTextStyle,
              ),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _showToast = false;
                    });
                  },
                  child: Icon(Icons.close))
            ],
          ),
          GestureDetector(
            onTap: () {}, //TODO: open link
            child: Row(
              children: [
                Text(
                  'Approved sDEA spend',
                  style: MyStyles.whiteMediumUnderlinedTextStyle,
                ),
                Transform.rotate(
                  angle: 150,
                  child: Icon(Icons.arrow_right_alt_outlined),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding _buildSteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 75),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              '1',
              style: MyStyles.whiteMediumTextStyle,
            ),
            decoration:
                BoxDecoration(gradient: gradient, shape: BoxShape.circle),
          ),
          Expanded(
              child: Container(
                  height: 3, decoration: BoxDecoration(gradient: gradient))),
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              '2',
              style: MyStyles.whiteMediumTextStyle,
            ),
            decoration: BoxDecoration(
                color: Color(MyColors.Button_BG_Black), shape: BoxShape.circle),
          )
        ],
      ),
    );
  }

  Widget _buildLockApproveButton() {
    return AnimatedCrossFade(
        firstChild: Row(
          children: [
            Expanded(
              child: FilledGradientSelectionButton(
                onPressed: () {
                  setState(() {
                    _lockState = LockStates.pendingApprove;
                    _showToast = true;
                  });
                  Future.delayed(Duration(seconds: 3), () {
                    setState(() {
                      _lockState = LockStates.canLock;
                    });
                  });
                },
                label: 'APPROVE',
                textStyle: MyStyles.blackMediumTextStyle,
                gradient: gradient,
              ),
            ),
            if (_lockState != LockStates.canLock)
              SizedBox(
                width: 15,
              ),
            Expanded(
              child: SizedBox(
                child: SelectionButton(
                  gradient: gradient,
                  child: _lockState == LockStates.pendingApprove
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                  onPressed: (bool) {},
                  label: 'LOCK',
                  selected: false,
                  textStyle: _lockState == LockStates.canLock
                      ? MyStyles.blackMediumTextStyle
                      : MyStyles.lightWhiteMediumTextStyle,
                ),
              ),
            )
          ],
        ),
        secondChild: SizedBox(
          width: double.infinity,
          child: SelectionButton(
              gradient: gradient,
              onPressed: (bool) {
                setState(() {
                  _lockState = LockStates.lockPendingApprove;
                  _showToast = true;
                  Future.delayed(Duration(seconds: 3), () {
                    setState(() {
                      _lockState = LockStates.lockApproved;
                    });
                  });
                });
              },
              label: 'LOCK',
              selected: true,
              textStyle: MyStyles.blackMediumTextStyle),
        ),
        crossFadeState: _lockState == LockStates.canLock ||
                _lockState == LockStates.lockPendingApprove ||
                _lockState == LockStates.lockApproved
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 150));
  }
}
