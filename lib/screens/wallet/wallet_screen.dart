
import 'package:deus_mobile/core/widgets/dark_button.dart';
import 'package:deus_mobile/core/widgets/default_screen/header_with_address.dart';
import 'package:deus_mobile/screens/wallet/widgets/chart_container.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';

enum StakingVaultOverviewScreenStates { Single, LiquidityClaim, LiquidityLockStake }

class StakingVaultOverviewScreen extends StatefulWidget {
  static const url = '/wallet-screen';

  @override
  _StakingVaultOverviewScreenState createState() => _StakingVaultOverviewScreenState();
}

class _StakingVaultOverviewScreenState extends State<StakingVaultOverviewScreen> {
  final String address = '0x3a6dabD6B5C75291a3258C29B418f5805792a87e';

  final double ethCount = 478.938;
  final double ethInUSD = 563008.67;
  final double percOfPool = 0.12;

  final double perfDEAns = 36.37;
  final double perfsUniDeusDea = 36.37;
  final double perfsDEA = 36.37;
  final double perfsDEUS = 36.37;
  final double perfsUniDeaUsdc = 36.37;
  final double perfsUUniDeuusEth = 36.37;

  final double nativeBalancerAPY = 99.98;
  final double timeTokenAPY = 199.98;
  final double sDeusAPY = 99.98;

  List<bool> _toggleButtonButtonsSingleLiquidity = [true, false];
  StakingVaultOverviewScreenStates _screenState = StakingVaultOverviewScreenStates.LiquidityLockStake;

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

  Divider _divider = Divider(height: 40);
  SizedBox _bigHeightDivider = SizedBox(
    height: 20,
  );
  SizedBox _midHeightDivider = SizedBox(
    height: 10,
  );
  SizedBox _smallHeightDivider = SizedBox(
    height: 5,
  );

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
              if (_screenState == StakingVaultOverviewScreenStates.Single)
                _buildSingleBottom(),
              if (_screenState == StakingVaultOverviewScreenStates.LiquidityClaim)
                _buildLiquidityClaim(),
              if (_screenState == StakingVaultOverviewScreenStates.LiquidityLockStake)
                _buildLiquidityLockStake(),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildSingleBottom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLockStakeButton(),
        _divider,
        _buildAPYAndPool(),
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

  Column _buildLiquidityClaim() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNativeBalancer(),
        _buildClaimSection(),
        _bigHeightDivider,
        _buildWithDrawClaim(),
        _bigHeightDivider,
        _buildStakeLockMoreButtons(),
        _divider,
      ],
    );
  }

  Column _buildLiquidityLockStake() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNativeBalancer(),
        _buildNativeBalancerLockStake(),
        _bigHeightDivider
      ],
    );
  }

  Padding _buildStakeLockMoreButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: DarkButton(
              label: 'LOCK MORE',
            ),
          ),
          SizedBox(width: 15),
          Expanded(child: DarkButton(label: 'STAKE MORE'))
        ],
      ),
    );
  }

  Padding _buildNativeBalancerLockStake() {
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
                child: DarkButton(
                  label: 'LOCK',
                ),
              ),
              SizedBox(width: 15),
              Expanded(child: DarkButton(label: 'STAKE'))
            ],
          )
        ],
      ),
    );
  }

  Padding _buildNativeBalancer() {
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
              if (_screenState == StakingVaultOverviewScreenStates.LiquidityClaim)
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

  Padding _buildTimeToken() {
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
                child: DarkButton(
                  label: 'LOCK',
                ),
              ),
              SizedBox(width: 15),
              Expanded(child: DarkButton(label: 'STAKE'))
            ],
          ),
          SizedBox(height: 30)
        ],
      ),
    );
  }

  Padding _buildAPYAndPool() {
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
                child: DarkButton(
                  label: 'LOCK',
                ),
              ),
              SizedBox(width: 15),
              Expanded(child: DarkButton(label: 'STAKE'))
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
          SizedBox(height: 8),
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
          SizedBox(height: 8),
          DarkButton(label: 'WITHDRAW & CLAIM'),
        ],
      ),
    );
  }
}
