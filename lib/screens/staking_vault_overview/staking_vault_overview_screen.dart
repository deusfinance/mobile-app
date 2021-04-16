import 'package:deus_mobile/core/widgets/dark_button.dart';
import 'package:deus_mobile/core/widgets/default_screen/header_with_address.dart';
import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/stake/stake_token_object.dart';
import 'package:deus_mobile/models/value_locked_chart_data.dart';
import 'package:deus_mobile/models/value_locked_screen_data.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/lock/lock_screen.dart';
import 'package:deus_mobile/screens/stake_screen/stake_screen.dart';
import 'package:deus_mobile/screens/staking_vault_overview/cubit/staking_vault_overview_cubit.dart';
import 'package:deus_mobile/screens/staking_vault_overview/cubit/staking_vault_overview_state.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_cubit.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
  void changeToggleButtonSingleLiquidity(int i) {
    context.read<StakingVaultOverviewCubit>().changeSingleLiquidity(i);
  }

  static const Divider _divider = Divider(height: 40);
  static const SizedBox _bigHeightDivider = SizedBox(height: 20);
  static const SizedBox _midHeightDivider = SizedBox(height: 10);
  static const SizedBox _smallHeightDivider = SizedBox(height: 5);

  @override
  void initState() {
    context.read<StakingVaultOverviewCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StakingVaultOverviewCubit, StakingVaultOverviewState>(
        builder: (context, state) {
          if (state is StakingVaultOverviewLoadingState) {
            return DefaultScreen(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
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
                      _buildToggleButton(state),
                      _divider,
                      _buildBottom(state),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  void navigateToLockScreen(BuildContext ctx,
      StakeTokenObject stakeTokenObject) {
    locator<NavigationService>().navigateTo(LockScreen.url, ctx,
        arguments: {"token_object": stakeTokenObject});
  }

  void navigateToStakeScreen(BuildContext ctx,
      StakeTokenObject stakeTokenObject) {
    locator<NavigationService>().navigateTo(StakeScreen.url, ctx,
        arguments: {"token_object": stakeTokenObject});
  }

  Widget _buildSingleBottom(StakingVaultOverviewState state) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: state.stakeTokenObjects.length,
        itemBuilder: (ctx, ind) {
          if (state.stakeTokenObjects[ind].isValueStaked()) {
            return _claimWidget(state.stakeTokenObjects[ind]);
          } else {
            return _lockStakeWidget(state.stakeTokenObjects[ind]);
          }
        });
  }

  Widget _buildLiquidityBottom(StakingVaultOverviewState state) {
    if (state.nativeBalancer.isValueStaked()) {
      return _buildLiquidityClaim(state.nativeBalancer);
    } else {
      return _buildLiquidityLockStake(state);
    }
  }

  Column _buildLiquidityClaim(StakeTokenObject object) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNativeBalancer(object),
        _buildClaimSection(object),
        _bigHeightDivider,
        _buildWithDrawClaim(object),
        _bigHeightDivider,
        _buildStakeLockMoreButtons(object),
        _divider,
      ],
    );
  }

  Column _buildLiquidityLockStake(StakingVaultOverviewState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNativeBalancer(state.nativeBalancer),
        _buildNativeBalancerLockStake(state),
        _bigHeightDivider
      ],
    );
  }

  _buildStakeButton(String label, BuildContext context,
      StakeTokenObject stakeTokenObject) {
    return DarkButton(
      label: label,
      onPressed: () => navigateToStakeScreen(context, stakeTokenObject),
    );
  }

  _buildLockButton(String label, BuildContext context,
      StakeTokenObject stakeTokenObject) {
    return DarkButton(
      label: label,
      onPressed: () {
        if (stakeTokenObject.lockToken == CurrencyData.bpt)
          lockBpt();
        else
          navigateToLockScreen(context, stakeTokenObject);
      },
    );
  }

  void lockBpt() async {
    String url = "https://pools.balancer.exchange/#/pool/0x1dc2948b6db34e38291090b825518c1e8346938b/";
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }


  Padding _buildStakeLockMoreButtons(StakeTokenObject stakeTokenObject) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: _buildLockButton('LOCK MORE', context, stakeTokenObject),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: _buildStakeButton('STAKE MORE', context, stakeTokenObject))
        ],
      ),
    );
  }

  Padding _buildNativeBalancerLockStake(StakingVaultOverviewState state) {
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
              Text('38.78%', style: MyStyles.whiteSmallTextStyle)
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
              Text('38.78%', style: MyStyles.whiteSmallTextStyle)
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
              Text('7.14%', style: MyStyles.whiteSmallTextStyle)
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
              Text('7.14%', style: MyStyles.whiteSmallTextStyle)
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
              Text('4.08%', style: MyStyles.whiteSmallTextStyle)
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
              Text('4.08%', style: MyStyles.whiteSmallTextStyle)
            ],
          ),
          _bigHeightDivider,
          Row(
            children: [
              Expanded(
                child: _buildLockButton('LOCK', context, state.nativeBalancer),
              ),
              const SizedBox(width: 15),
              Expanded(
                  child:
                  _buildStakeButton('STAKE', context, state.nativeBalancer))
            ],
          )
        ],
      ),
    );
  }

  Padding _buildNativeBalancer(StakeTokenObject object) {
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
                '${object.apy}% APY',
                style: MyStyles.whiteMediumTextStyle,
              ),
              if (object.isValueStaked())
                Text(
                  'you own ${object.percOfPool()}% of the pool',
                  style: MyStyles.whiteSmallTextStyle,
                )
            ],
          ),
          _midHeightDivider
        ],
      ),
    );
  }

  Padding _buildAPYAndPool(StakeTokenObject object) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(object.stakeToken.name, style: MyStyles.whiteBigTextStyle),
            Text('you own ${object.percOfPool}% of the pool',
                style: MyStyles.whiteSmallTextStyle)
          ]),
          _smallHeightDivider,
          Text('${object.apy}% APY', style: MyStyles.whiteMediumTextStyle)
        ],
      ),
    );
  }

  Padding _buildToggleButton(StakingVaultOverviewState state) {
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
              style: state is StakingVaultOverviewSingleState
                  ? MyStyles.selectedToggleButtonTextStyle
                  : MyStyles.unselectedToggleButtonTextStyle,
            ),
          ),
          Text('Liquidity',
              style: state is StakingVaultOverviewLiquidityState
                  ? MyStyles.selectedToggleButtonTextStyle
                  : MyStyles.unselectedToggleButtonTextStyle)
        ],
        isSelected: state is StakingVaultOverviewSingleState
            ? [true, false]
            : [false, true],
      ),
    );
  }

  Padding _buildClaimSection(StakeTokenObject object) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child:
            Text(object.pendingReward, style: MyStyles.whiteSmallTextStyle),
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

  Padding _buildWithDrawClaim(StakeTokenObject object) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child:
            Text(object.pendingReward, style: MyStyles.whiteSmallTextStyle),
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

  Widget _lockStakeWidget(StakeTokenObject stakeTokenObject) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stakeTokenObject.stakeToken.name,
            style: MyStyles.whiteBigTextStyle,
          ),
          _smallHeightDivider,
          Text(
            '${stakeTokenObject.apy}% APY',
            style: MyStyles.whiteMediumTextStyle,
          ),
          _midHeightDivider,
          Row(
            children: [
              Expanded(
                child: _buildLockButton('LOCK', context, stakeTokenObject),
              ),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildStakeButton('STAKE', context, stakeTokenObject))
            ],
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }

  Widget _claimWidget(StakeTokenObject object) {
    return Column(
      children: [
        _buildAPYAndPool(object),
        _buildClaimSection(object),
        _bigHeightDivider,
        _buildWithDrawClaim(object),
        _bigHeightDivider,
        _buildStakeLockMoreButtons(object),
        const SizedBox(height: 30)
      ],
    );
  }

  Widget _buildBottom(StakingVaultOverviewState state) {
    if (state is StakingVaultOverviewSingleState) {
      return _buildSingleBottom(state);
    } else if (state is StakingVaultOverviewLiquidityState) {
      return _buildLiquidityBottom(state);
    } else {
      return CircularProgressIndicator();
    }
  }
}
