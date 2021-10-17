import '../screens/blurred_stake_lock_screen/blurred_stake_lock_screen.dart';
import '../screens/blurred_synthetics_screen/blurred_synthetics_screen.dart';
import '../screens/swap/cubit/swap_cubit.dart';
import '../screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_cubit.dart';
import '../screens/synthetics/xdai_synthetics/xdai_synthetics_screen.dart';
import '../screens/wallet/cubit/wallet_cubit.dart';
import '../screens/wallet/wallet_screen.dart';
import '../statics/styles.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/swap/swap_screen.dart';

class NavigationItem extends Equatable {
  final Widget page;
  final String title;
  final String routeUrl;
  final NavigationStyle style;

  const NavigationItem({
    required this.page,
    required this.title,
    this.style = NavigationStyle.BluePurple,
    required this.routeUrl,
  });

  static final NavigationItem swap = NavigationItem(
      page: BlocProvider<SwapCubit>(
          create: (_) => SwapCubit(), child: const SwapScreen()),
      title: "Swap",
      routeUrl: SwapScreen.route,
      style: NavigationStyle.GreenBlue);

  static final NavigationItem synthetics = NavigationItem(
      page: BlocProvider<XDaiSyntheticsCubit>(
          create: (_) => XDaiSyntheticsCubit(), child: XDaiSyntheticsScreen()),
      title: "Synthetics",
      routeUrl: XDaiSyntheticsScreen.route,
      style: NavigationStyle.BluePurple);

  // static final NavigationItem stakeAndLockOverview = NavigationItem(
  //     page: StakingVaultOverviewScreen(),
  //     title: "Lock and Stake",
  //     routeUrl: StakingVaultOverviewScreen.url,
  //     style: NavigationStyle.BlueGreen);

  static final NavigationItem blurredSynthethics = NavigationItem(
      page: BlurredSyntheticsScreen(), //SynchronizerScreen(),
      title: "Synthetics",
      routeUrl: BlurredSyntheticsScreen.url);

  static final NavigationItem blurredStakeAndLockOverview = NavigationItem(
      page: BlurredStakeLockScreen(),
      title: "Lock and Stake",
      routeUrl: BlurredStakeLockScreen.url,
      style: NavigationStyle.BlueGreen);

  static final NavigationItem wallet = NavigationItem(
      page: BlocProvider<WalletCubit>(
          create: (_) => WalletCubit(), child: WalletScreen()),
      title: "Wallet",
      routeUrl: WalletScreen.route,
      style: NavigationStyle.BlueGreen);

  static List<NavigationItem> get items => [swap, synthetics, wallet];

  @override
  List<Object> get props => [title];
}
