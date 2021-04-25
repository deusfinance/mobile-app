import 'package:deus_mobile/screens/blurred_stake_lock_screen/blurred_stake_lock_screen.dart';
import 'package:deus_mobile/screens/blurred_synthetics_screen/blurred_synthetics_screen.dart';
import 'package:deus_mobile/screens/lock/lock_screen.dart';
import 'package:deus_mobile/screens/staking_vault_overview/staking_vault_overview_screen.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_cubit.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/xdai_synthetics_screen.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/stake_screen/stake_screen.dart';
import '../screens/swap/swap_screen.dart';

class NavigationItem extends Equatable {
  final Widget page;
  final String title;
  final String routeUrl;
  final NavigationStyle style;

  const NavigationItem({
    @required this.page,
    @required this.title,
    this.style = NavigationStyle.BluePurple,
    @required this.routeUrl,
  });

  static final NavigationItem swap = NavigationItem(
      page: BlocProvider<SwapCubit>(create: (_) => SwapCubit(), child: SwapScreen()),
      title: "Swap",
      routeUrl: SwapScreen.route,
      style: NavigationStyle.GreenBlue);

  static final NavigationItem synthethics = NavigationItem(
      page: BlocProvider<XDaiSyntheticsCubit>(create: (_) => XDaiSyntheticsCubit(), child: XDaiSyntheticsScreen()),
      title: "Synthetics",
      routeUrl: XDaiSyntheticsScreen.route,
      style: NavigationStyle.BluePurple);


  static final NavigationItem stakeAndLockOverview = NavigationItem(
      page: BlurredStakeLockScreen(),
      title: "Lock and Stake",
      routeUrl: StakingVaultOverviewScreen.url,
      style: NavigationStyle.BlueGreen);

  static final NavigationItem staking = NavigationItem(
      page: StakeScreen(), title: "Staking", routeUrl: StakeScreen.url);

  static final NavigationItem vaults = NavigationItem(
      page: LockScreen(), title: "Vaults", routeUrl: LockScreen.url);


  // static final NavigationItem synthethics = NavigationItem(
  //     page: BlurredSyntheticsScreen(), //SynchronizerScreen(),
  //     title: "Synthetics",
  //     routeUrl: BlurredSyntheticsScreen.url);

  static List<NavigationItem> get items =>
      [swap, synthethics, stakeAndLockOverview];

  @override
  List<Object> get props => [title];
}
