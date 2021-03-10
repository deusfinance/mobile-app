import 'package:deus_mobile/screens/swap/cubit/swap_cubit.dart';
import 'package:deus_mobile/screens/swap/swap_screen_backup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          page: BlocProvider<SwapCubit>(
              create: (context) => SwapCubit(),
              child: SwapScreen()
          ),
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
