import 'package:deus/screens/stake_screen/stake_screen.dart';
import 'package:deus/screens/staking/stacking_screen.dart';
import 'package:deus/screens/swap/swap_screen.dart';
import 'package:deus/screens/synthetics/synthetics_screen.dart';
import 'package:deus/screens/test_screen.dart';
import 'package:deus/screens/vaults/vaults_screen.dart';
import 'package:flutter/material.dart';

import '../synthetics/synchronizer_screen.dart';

class MyNavigationItem {
  final Widget page;
  final String title;

  MyNavigationItem({
    @required this.page,
    @required this.title,
  });

  static List<MyNavigationItem> get items => [
         MyNavigationItem(
           page: SwapScreen(),
           title:"Swap",
         ),
//        MyNavigationItem(
//          page: SwapBackendTestScreen(),
//          title: "Swap Test",
//        ),
        MyNavigationItem(
          page:  SyntheticsScreen(), //SynchronizerScreen(),
          title: "Synthetics",
        ),
        MyNavigationItem(
          page: StakeScreen(),
          title: "Staking",
        ),
        MyNavigationItem(
          page: VaultsScreen(),
          title: "Vaults",
        ),
      ];
}
