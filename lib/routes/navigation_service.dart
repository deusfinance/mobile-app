import 'package:deus_mobile/routes/navigation_item.dart';
import 'package:flutter/material.dart';

class NavigationService {
  NavigationItem selectedNavItem;
  NavigationService({@required this.selectedNavItem});

  bool isSelected(NavigationItem item) => selectedNavItem == item;

  void navigateTo(String route, BuildContext context) => Navigator.pushNamed(context, route);
}
