import 'package:deus_mobile/core/widgets/dark_button.dart';
import 'package:deus_mobile/core/widgets/default_screen/header_with_address.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/value_locked_chart_data.dart';
import 'package:deus_mobile/models/value_locked_screen_data.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/lock/lock_screen.dart';
import 'package:deus_mobile/screens/stake_screen/stake_screen.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';

import 'widgets/chart_container.dart';

enum StakingVaultOverviewScreenStates {
  Single,
  LiquidityClaim,
  LiquidityLockStake
}

class StakingVaultOverviewScreen extends StatefulWidget {
  static const url = '/wallet-screen';

  @override
  _StakingVaultOverviewScreenState createState() =>
      _StakingVaultOverviewScreenState();
}

class _StakingVaultOverviewScreenState
    extends State<StakingVaultOverviewScreen> {
  final String address = '0x3a6dabD6B5C75291a3258C29B418f5805792a87e';


  Future<ValueLockedScreenData> _testData() async {
    await Future.delayed(Duration(seconds: 3));
    return ValueLockedScreenData(
        ethCount: 478.938,
        ethInUSD: 563008.67,
        nativeBalancerAPY: 99.98,
        percOfPool: 0.12,
        perfDEAns: 36.37,
        perfsDEA: 36.37,
        perfsDEUS: 36.37,
        perfsUniDeusDea: 36.37,
        perfsUniDeaUsdc: 36.37,
        perfsUUniDeuusEth: 36.37,
        timeTokenAPY: 199.98,
        sDeusAPY: 99.98);
  }

  List<bool> _toggleButtonButtonsSingleLiquidity = [true, false];
  StakingVaultOverviewScreenStates _screenState =
      StakingVaultOverviewScreenStates.Single;

  void changeToggleButtonSingleLiquidity(int i) {
    if (!_toggleButtonButtonsSingleLiquidity[i]) {
      _toggleButtonButtonsSingleLiquidity = [false, false];
      setState(() {
        _toggleButtonButtonsSingleLiquidity[i] = true;
      });
      setState(() {
        _screenState = _toggleButtonButtonsSingleLiquidity[0]
            ? StakingVaultOverviewScreenStates.Single
            : StakingVaultOverviewScreenStates.LiquidityClaim;
      });
    }
  }

  static const Divider _divider = Divider(height: 40);
  static const SizedBox _bigHeightDivider = SizedBox(height: 20);
  static const SizedBox _midHeightDivider = SizedBox(height: 10);
  static const SizedBox _smallHeightDivider = SizedBox(height: 5);

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _midHeightDivider,
              ChartContainer(),
              _bigHeightDivider,
              _buildToggleButton(),
              _divider,
              FutureBuilder(
                  future: _testData(),
                  builder: (context, snapshot) {
                    return
                      snapshot.connectionState == ConnectionState.done ?
                      Column(
                      children: [
                        if (_screenState ==
                            StakingVaultOverviewScreenStates.Single)
                          _buildSingleBottom(snapshot.data),
                        if (_screenState ==
                            StakingVaultOverviewScreenStates.LiquidityClaim)
                          _buildLiquidityClaim(snapshot.data),
                        if (_screenState ==
                            StakingVaultOverviewScreenStates.LiquidityLockStake)
                          _buildLiquidityLockStake(snapshot.data),
                      ],
                    ): Center(child: CircularProgressIndicator(),);
                  })
            ],
          ),
        ),
      ),
    );
  }

  void navigateToLockScreen(BuildContext ctx) {
    locator<NavigationService>().navigateTo(LockScreen.url, ctx);
  }

  void navigateToStakeScreen(BuildContext ctx) {
    locator<NavigationService>().navigateTo(StakeScreen.url, ctx);
  }

  Column _buildSingleBottom(ValueLockedScreenData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLockStakeButton(),
        _divider,
        _buildAPYAndPool(sDeusAPY: data.sDeusAPY, percOfPool: data.percOfPool),
        _buildClaimSection(),
        _bigHeightDivider,
        _buildWithDrawClaim(),
        _bigHeightDivider,
        _buildStakeLockMoreButtons(),
        _divider,
        _buildTimeToken()
      ],
    );
  }

  Column _buildLiquidityClaim(ValueLockedScreenData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNativeBalancer(
            nativeBalancerAPY: data.nativeBalancerAPY,
            percOfPool: data.percOfPool),
        _buildClaimSection(),
        _bigHeightDivider,
        _buildWithDrawClaim(),
        _bigHeightDivider,
        _buildStakeLockMoreButtons(),
        _divider,
      ],
    );
  }

  Column _buildLiquidityLockStake(ValueLockedScreenData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNativeBalancer(
            nativeBalancerAPY: data.nativeBalancerAPY,
            percOfPool: data.percOfPool),
        _buildNativeBalancerLockStake(
            perfsUUniDeuusEth: data.perfsUUniDeuusEth,
            perfsUniDeaUsdc: data.perfsUniDeaUsdc,
            perfsUniDeusDea: data.perfsUniDeusDea,
            perfsDEUS: data.perfsDEUS,
            perfsDEA: data.perfsDEA,
            perfDEAns: data.perfDEAns),
        _bigHeightDivider
      ],
    );
  }

  _buildStakeButton(String label, BuildContext context) {
    return DarkButton(
      label: label,
      onPressed: () => navigateToStakeScreen(context),
    );
  }

  _buildLockButton(String label, BuildContext context) {
    return DarkButton(
      label: label,
      onPressed: () => navigateToLockScreen(context),
    );
  }

  Padding _buildStakeLockMoreButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: _buildLockButton('LOCK MORE', context),
          ),
          const SizedBox(width: 15),
          Expanded(child: _buildStakeButton('STAKE MORE', context))
        ],
      ),
    );
  }

  Padding _buildNativeBalancerLockStake(
      {perfDEAns,
      perfsUniDeusDea,
      perfsDEA,
      perfsDEUS,
      perfsUniDeaUsdc,
      perfsUUniDeuusEth}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Text(
            'In order to stake you need to provide liquidity to the following Balancer pool',
            style: MyStyles.whiteSmallTextStyle,
          ),
          _bigHeightDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DEA (not sealed)',
                style: MyStyles.whiteSmallTextStyle,
              ),
              Text('$perfDEAns%', style: MyStyles.whiteSmallTextStyle)
            ],
          ),
          _smallHeightDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sUNI DEUS-DEA',
                style: MyStyles.whiteSmallTextStyle,
              ),
              Text('$perfsUniDeusDea%', style: MyStyles.whiteSmallTextStyle)
            ],
          ),
          _smallHeightDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sDEA',
                style: MyStyles.whiteSmallTextStyle,
              ),
              Text('$perfsDEA%', style: MyStyles.whiteSmallTextStyle)
            ],
          ),
          _smallHeightDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sDEUS',
                style: MyStyles.whiteSmallTextStyle,
              ),
              Text('$perfsDEUS%', style: MyStyles.whiteSmallTextStyle)
            ],
          ),
          _smallHeightDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sUNI DEA-USDC',
                style: MyStyles.whiteSmallTextStyle,
              ),
              Text('$perfsUniDeaUsdc%', style: MyStyles.whiteSmallTextStyle)
            ],
          ),
          _smallHeightDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sUUNI DEUUS-ETH',
                style: MyStyles.whiteSmallTextStyle,
              ),
              Text('$perfsUUniDeuusEth%', style: MyStyles.whiteSmallTextStyle)
            ],
          ),
          _bigHeightDivider,
          Row(
            children: [
              Expanded(
                child: _buildLockButton('LOCK', context),
              ),
              const SizedBox(width: 15),
              Expanded(child: _buildStakeButton('STAKE', context))
            ],
          )
        ],
      ),
    );
  }

  Padding _buildNativeBalancer({nativeBalancerAPY, percOfPool}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Native Balancer',
            style: MyStyles.whiteBigTextStyle,
          ),
          _smallHeightDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$nativeBalancerAPY% APY',
                style: MyStyles.whiteMediumTextStyle,
              ),
              if (_screenState ==
                  StakingVaultOverviewScreenStates.LiquidityClaim)
                Text(
                  'you own $percOfPool% of the pool',
                  style: MyStyles.whiteSmallTextStyle,
                )
            ],
          ),
          _midHeightDivider
        ],
      ),
    );
  }

  Padding _buildTimeToken({timeTokenAPY}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIME TOKEN',
            style: MyStyles.whiteBigTextStyle,
          ),
          _smallHeightDivider,
          Text(
            '$timeTokenAPY% APY',
            style: MyStyles.whiteMediumTextStyle,
          ),
          _midHeightDivider,
          Row(
            children: [
              Expanded(
                child: _buildLockButton('LOCK', context),
              ),
              const SizedBox(width: 15),
              Expanded(child: _buildStakeButton('STAKE', context))
            ],
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }

  Padding _buildAPYAndPool({percOfPool, sDeusAPY}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('sDEUS', style: MyStyles.whiteBigTextStyle),
            Text('you own $percOfPool% of the pool',
                style: MyStyles.whiteSmallTextStyle)
          ]),
          _smallHeightDivider,
          Text('$sDeusAPY% APY', style: MyStyles.whiteMediumTextStyle)
        ],
      ),
    );
  }

  Padding _buildToggleButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ToggleButtons(
          fillColor: Colors.transparent,
          onPressed: (int ind) => changeToggleButtonSingleLiquidity(ind),
          renderBorder: false,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Text(
                'Single',
                style: _toggleButtonButtonsSingleLiquidity[0]
                    ? MyStyles.selectedToggleButtonTextStyle
                    : MyStyles.unselectedToggleButtonTextStyle,
              ),
            ),
            Text('Liquidity',
                style: _toggleButtonButtonsSingleLiquidity[1]
                    ? MyStyles.selectedToggleButtonTextStyle
                    : MyStyles.unselectedToggleButtonTextStyle)
          ],
          isSelected: _toggleButtonButtonsSingleLiquidity),
    );
  }

  Padding _buildLockStakeButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'sDEA',
            style: MyStyles.whiteBigTextStyle,
          ),
          _smallHeightDivider,
          Text(
            '99.93% APY',
            style: MyStyles.whiteMediumTextStyle,
          ),
          _midHeightDivider,
          Row(
            children: [
              Expanded(
                child: _buildLockButton('LOCK', context),
              ),
              const SizedBox(width: 15),
              Expanded(child: _buildStakeButton('STAKE', context))
            ],
          )
        ],
      ),
    );
  }

  Padding _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          HeaderWithAddress(walletAddress: address),
          _midHeightDivider,
        ],
      ),
    );
  }

  Padding _buildClaimSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Text('1.345646', style: MyStyles.whiteSmallTextStyle),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MyColors.HalfBlack)),
          ),
          const SizedBox(height: 8),
          DarkButton(label: 'CLAIM'),
        ],
      ),
    );
  }

  Padding _buildWithDrawClaim() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Text('1.345646', style: MyStyles.whiteSmallTextStyle),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MyColors.HalfBlack)),
          ),
          const SizedBox(height: 8),
          DarkButton(label: 'WITHDRAW & CLAIM'),
        ],
      ),
    );
  }
}
