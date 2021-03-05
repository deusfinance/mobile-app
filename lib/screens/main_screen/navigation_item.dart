
import 'package:deus_mobile/screens/staking/stacking_screen.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_screen.dart';
import 'package:deus_mobile/screens/test_screen.dart';
import 'package:deus_mobile/screens/vaults/vaults_screen.dart';

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
