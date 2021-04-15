import 'package:deus_mobile/routes/navigation_item.dart';
import 'package:deus_mobile/routes/route_generator.dart';
import 'package:flutter/material.dart';

class NavigationService {
  NavigationItem selectedNavItem;
  NavigationService({@required this.selectedNavItem});

  bool isSelected(NavigationItem item) => selectedNavItem == item;

  Future navigateTo(String routeName, BuildContext context, {bool replace = false, bool replaceAll = false , arguments}) {
    if (replace)
      Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
    else if (replaceAll)
      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false, arguments: arguments);
    else
      return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  void goBack(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }
}
