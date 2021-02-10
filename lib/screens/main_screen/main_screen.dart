import 'package:deus/screens/main_screen/bottom_nav_bar.dart';
import 'package:deus/screens/main_screen/navigation_item.dart';
import 'package:deus/screens/synthetics/synthetics_screen.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          Row(
            children: [
              Text("wallet")
            ],
          ),
          IndexedStack(
            index: _currentIndex,
            children: [
              for (final tabItem in MyNavigationItem.items) tabItem.page,
            ],
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
