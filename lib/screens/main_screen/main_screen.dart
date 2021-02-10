import 'package:flutter/material.dart';

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
      backgroundColor: Color(MyColors.Main_BG_Black),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (final tabItem in MyNavigationItem.items) tabItem.page,
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
