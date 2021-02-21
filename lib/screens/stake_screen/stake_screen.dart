import 'dart:ui';

import 'package:deus/core/widgets/dark_button.dart';
import 'package:deus/core/widgets/filled_gradient_selection_button.dart';
import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/core/widgets/svg.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

enum StakesStates {
  hasToApprove,
  pendingApprove,
  canStake,
  stakePendingApprove,
  stakeApproved
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

  StakesStates _stakeState = StakesStates.hasToApprove;
  bool _showToast = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColors.Background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: SizedBox(
            height: MediaQuery.of(context).size.height-80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderAddress(),
                SizedBox(
                  height: 23,
                ),
                _buildBackButton(),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Stake your sDEA',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '$apy% APY',
                  style: TextStyle(fontSize: 20),
                ),
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
                _buildTextField(),
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
                _buildStakeApproveButton(),
                SizedBox(
                  height: 15,
                ),
                if (_stakeState == StakesStates.hasToApprove)
                  _buildSteps(),
                Spacer(),
                if ((_stakeState != StakesStates.hasToApprove && _showToast) || (_stakeState == StakesStates.stakePendingApprove && _showToast))
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
          color: _stakeState != StakesStates.pendingApprove && _stakeState != StakesStates.stakePendingApprove
              ? Color(MyColors.ToastGreen)
              : Color(MyColors.ToastGrey)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _stakeState != StakesStates.pendingApprove && _stakeState != StakesStates.stakePendingApprove
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
          Row(
            children: [
              Text(
                'Approved sDEA spend ↗',
                style: MyStyles.whiteMediumUnderlinedTextStyle,
              )
            ],
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

  Widget _buildStakeApproveButton() {
    return AnimatedCrossFade(
        firstChild: Row(
          children: [
            Expanded(
              child: FilledGradientSelectionButton(
                onPressed: () {
                  setState(() {
                    _stakeState = StakesStates.pendingApprove;
                    _showToast = true;
                  });
                  Future.delayed(Duration(seconds: 3), () {
                    setState(() {
                      _stakeState = StakesStates.canStake;
                    });
                  });
                },
                label: 'APPROVE',
                textStyle: MyStyles.blackMediumTextStyle,
                gradient: gradient,
              ),
            ),
            if (_stakeState != StakesStates.canStake)
              SizedBox(
                width: 15,
              ),
            Expanded(
              child: SizedBox(
                child: SelectionButton(
                  gradient: gradient,
                  child: _stakeState == StakesStates.pendingApprove
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
                  label: 'STAKE',
                  selected: false,
                  textStyle: _stakeState == StakesStates.canStake
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
              onPressed: (bool) {setState(() {
                _stakeState = StakesStates.stakePendingApprove;
                _showToast = true;
                Future.delayed(Duration(seconds: 3), () {
                  setState(() {
                    _stakeState = StakesStates.stakeApproved;
                  });
                });
              });},
              label: 'STAKE',
              selected: true,
              textStyle: MyStyles.blackMediumTextStyle),
        ),
        crossFadeState: _stakeState == StakesStates.canStake || _stakeState == StakesStates.stakePendingApprove || _stakeState == StakesStates.stakeApproved
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 150));
  }

  Container _buildTextField() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
          color: Color(MyColors.Button_BG_Black),
          border: Border.all(color: Colors.white.withOpacity(0.1))),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        cursorColor: Colors.white,
        style: MyStyles.lightWhiteMediumTextStyle,
        decoration: InputDecoration(
            hintText: '0.00',
            focusedErrorBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: Text(
                'MAX',
                style: MyStyles.whiteSmallTextStyle,
              ),
              decoration: BoxDecoration(
                  color: Color(0xFF5BCCBD).withOpacity(0.25),
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(7)),
            )),
      ),
    );
  }

  GestureDetector _buildBackButton() {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios_rounded,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            'BACK',
            style: MyStyles.whiteMediumTextStyle,
          )
        ],
      ),
    );
  }

  Row _buildHeaderAddress() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF61C0BF).withOpacity(0.5)),
              color: Color(0xFF61C0BF).withOpacity(0.25),
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: Center(
            child: Text(
              '${address.substring(0, 4)}...${address.substring(address.length - 2)}',
              style: MyStyles.whiteSmallTextStyle,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
            onTap: () {}, child: PlatformSvg.asset('images/logout.svg')),
      ],
    );
  }
}
