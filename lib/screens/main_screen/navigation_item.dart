import 'package:flutter/material.dart';

import '../stake_screen/stake_screen.dart';
import '../swap/swap_screen.dart';
import '../synthetics/synthetics_screen.dart';
import '../vaults/vaults_screen.dart';

class MyNavigationItem {
  final Widget page;
  final String title;
  final void Function(BuildContext context) onPressed;

  MyNavigationItem({
    @required this.page,
    this.onPressed,
    @required this.title,
  });

  static List<MyNavigationItem> get items => [
        MyNavigationItem(
          page: SwapScreen(),
          title: "Swap",
        ),
//        MyNavigationItem(
//          page: SwapBackendTestScreen(),
//          title: "Swap Test",
//        ),
        MyNavigationItem(
          page: SyntheticsScreen(), //SynchronizerScreen(),
          title: "Synthetics",
        ),
        MyNavigationItem(
          onPressed: (BuildContext context) => Navigator.of(context).pushNamed(StakeScreen.url),
          page: StakeScreen(),
          title: "Staking",
        ),
        MyNavigationItem(
          page: VaultsScreen(),
          title: "Vaults",
        ),
      ];
}
