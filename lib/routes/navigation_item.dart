import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../screens/stake_screen/stake_screen.dart';
import '../screens/swap/swap_screen.dart';
import '../screens/synthetics/synthetics_screen.dart';
import '../screens/vaults/vaults_screen.dart';

class NavigationItem extends Equatable {
  final Widget page;
  final String title;
  final void Function(BuildContext context) onPressed;

  const NavigationItem({
    @required this.page,
    this.onPressed,
    @required this.title,
  });

  static const NavigationItem swap = NavigationItem(page: SwapScreen(), title: "Swap");
  static const NavigationItem staking = NavigationItem(page: StakeScreen(), title: "Staking");
  static const NavigationItem vaults = NavigationItem(page: VaultsScreen(), title: "Vaults");

  static const NavigationItem synthethics = NavigationItem(
    page: SyntheticsScreen(), //SynchronizerScreen(),
    title: "Synthetics",
  );

  static List<NavigationItem> get items => [
        swap,
        synthethics,
        staking,
        vaults,
      ];

  @override
  List<Object> get props => [title];
}
