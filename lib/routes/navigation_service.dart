import 'package:deus_mobile/routes/navigation_item.dart';
import 'package:deus_mobile/routes/route_generator.dart';
import 'package:flutter/material.dart';

class NavigationService {
  NavigationItem selectedNavItem;
  NavigationService({@required this.selectedNavItem});

  bool isSelected(NavigationItem item) => selectedNavItem == item;

  void navigateTo(String routeName, BuildContext context, {bool replace = false}) {
    if (replace)
      Navigator.pushReplacementNamed(context, routeName);
    else
      Navigator.pushNamed(context, routeName);
  }

  void goBack(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }
}
