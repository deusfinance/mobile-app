import '../../../routes/navigation_item.dart';
import '../../../routes/navigation_service.dart';
import '../../../statics/my_colors.dart';
import '../../../statics/styles.dart';
import 'package:flutter/material.dart';

import '../../../locator.dart';

class MyBottomNavBar extends StatelessWidget {
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
          children: NavigationItem.items
              .map((item) => _buildNavItem(item, context))
              .toList()),
    );
  }

  InkWell _buildNavItem(NavigationItem item, BuildContext context) {
    return InkWell(
        onTap: () {
          locator<NavigationService>().selectedNavItem = item;
          locator<NavigationService>()
              .navigateTo(item.routeUrl, context, replaceAll: true);
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                item.title,
                style: locator<NavigationService>().isSelected(item)
                    ? TextStyle(
                        fontFamily: MyStyles.kFontFamily,
                        fontWeight: FontWeight.w300,
                        fontSize: MyStyles.S5,
                        foreground: Paint()
                          ..shader = _getGradient(item)
                              .createShader(const Rect.fromLTRB(0, 0, 50, 30)))
                    : MyStyles.bottomNavBarUnSelectedStyle,
              ),
              Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  height: 3.0,
                  width: (MediaQuery.of(context).size.width - 50) / 4,
                  decoration: locator<NavigationService>().isSelected(item)
                      ? _getDecoration(item)
                      : BoxDecoration(color: MyColors.Main_BG_Black))
            ],
          ),
        ));
  }

  Decoration _getDecoration(NavigationItem item) {
    if (item.style == NavigationStyle.GreenBlue)
      return MyStyles.greenToBlueDecoration;
    else if (item.style == NavigationStyle.BlueGreen)
      return MyStyles.blueToGreenDecoration;
    else
      return MyStyles.blueToPurpleDecoration;
  }

  Gradient _getGradient(NavigationItem item) {
    if (item.style == NavigationStyle.GreenBlue)
      return MyColors.greenToBlueGradient;
    else if (item.style == NavigationStyle.BlueGreen)
      return MyColors.blueToGreenGradient;
    else
      return MyColors.blueToPurpleGradient;
  }
}
