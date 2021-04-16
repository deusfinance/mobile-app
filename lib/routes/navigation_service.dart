import 'package:deus_mobile/routes/navigation_item.dart';
import 'package:deus_mobile/routes/route_generator.dart';
import 'package:flutter/material.dart';

class NavigationService {
  NavigationItem selectedNavItem;
  NavigationService({@required this.selectedNavItem});

  bool canGoBack(BuildContext context) => Navigator.canPop(context);

  bool isSelected(NavigationItem item) => selectedNavItem == item;

  Future navigateTo(String routeName, BuildContext context, {bool replace = false, bool replaceAll = false}) {
    if (replace)
      Navigator.pushReplacementNamed(context, routeName);
    else if (replaceAll)
      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    else
      return Navigator.pushNamed(context, routeName);
  }

  void goBack(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }
}
