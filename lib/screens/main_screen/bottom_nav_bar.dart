import 'package:deus_mobile/screens/main_screen/navigation_item.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBottomNavBar extends StatefulWidget {
  final ValueChanged<int> onTabSelected;

  MyBottomNavBar(this.onTabSelected);

  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;

  updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          color: MyColors.Main_BG_Black,
          border: Border(
            top: BorderSide(width: 1.0, color: MyColors.HalfBlack),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
              onTap: () {
                updateIndex(0);
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      MyNavigationItem.items[0].title,
                      style: _selectedIndex == 0
                          ? TextStyle(
                              fontFamily: MyStyles.kFontFamily,
                              fontWeight: FontWeight.w300,
                              fontSize: MyStyles.S5,
                              foreground: Paint()
                                ..shader = MyColors.greenToBlueGradient.createShader(Rect.fromLTRB(0, 0, 50, 30)))
                          : MyStyles.bottomNavBarUnSelectedStyle,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        height: 3.0,
                        width: (MediaQuery.of(context).size.width - 50) / 4,
                        decoration: _selectedIndex == 0
                            ? MyStyles.greenToBlueDecoration
                            : BoxDecoration(
                                color: MyColors.Main_BG_Black))
                  ],
                ),
              )),
          GestureDetector(
              onTap: () {
                updateIndex(1);
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      MyNavigationItem.items[1].title,
                      style: _selectedIndex == 1
                          ? TextStyle(
                              fontFamily: MyStyles.kFontFamily,
                              fontWeight: FontWeight.w300,
                              fontSize: MyStyles.S5,
                              foreground: Paint()
                                ..shader = MyColors.blueToPurpleGradient.createShader(Rect.fromLTRB(0, 0, 50, 30)))
                          : MyStyles.bottomNavBarUnSelectedStyle,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        height: 3.0,
                        width: (MediaQuery.of(context).size.width - 50) / 4,
                        decoration: _selectedIndex == 1
                            ? MyStyles.blueToPurpleDecoration
                            : BoxDecoration(
                                color: MyColors.Main_BG_Black))
                  ],
                ),
              )),
          GestureDetector(
              onTap: () {
                updateIndex(2);
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      MyNavigationItem.items[2].title,
                      style: _selectedIndex == 2
                          ? TextStyle(
                              fontFamily: MyStyles.kFontFamily,
                              fontWeight: FontWeight.w300,
                              fontSize: MyStyles.S5,
                              foreground: Paint()
                                ..shader = MyColors.blueToPurpleGradient.createShader(Rect.fromLTRB(0, 0, 100, 30)))
                          : MyStyles.bottomNavBarUnSelectedStyle,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        height: 3.0,
                        width: (MediaQuery.of(context).size.width - 50) / 4,
                        decoration: _selectedIndex == 2
                            ? MyStyles.blueToPurpleDecoration
                            : BoxDecoration(
                                color: MyColors.Main_BG_Black))
                  ],
                ),
              )),
          GestureDetector(
              onTap: () {
                updateIndex(3);
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      MyNavigationItem.items[3].title,
                      style: _selectedIndex == 3
                          ? TextStyle(
                              fontFamily: MyStyles.kFontFamily,
                              fontWeight: FontWeight.w300,
                              fontSize: MyStyles.S5,
                              foreground: Paint()
                                ..shader = MyColors.blueToPurpleGradient.createShader(Rect.fromLTRB(0, 0, 100, 30)))
                          : MyStyles.bottomNavBarUnSelectedStyle,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        height: 3.0,
                        width: (MediaQuery.of(context).size.width - 50) / 4,
                        decoration: _selectedIndex == 3
                            ? MyStyles.blueToPurpleDecoration
                            : BoxDecoration(
                                color: MyColors.Main_BG_Black))
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
