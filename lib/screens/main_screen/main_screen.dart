import 'package:flutter/material.dart';

import '../../core/widgets/header_with_address.dart';
import '../../locator.dart';
import '../../service/address_service.dart';
import '../../service/config_service.dart';
import '../../statics/my_colors.dart';
import 'bottom_nav_bar.dart';
import 'navigation_item.dart';

class MainScreen extends StatefulWidget {
  static const route = "/main";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.Main_BG_Black,
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Container(
            margin: EdgeInsets.only(right: 8, left: 8),
            child: HeaderWithAddress(),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                for (final tabItem in MyNavigationItem.items) tabItem.page,
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(onTabSelected),
    );
  }

  void onTabSelected(int value) {
    setState(() {
      _currentIndex = value;
    });
  }
}
