import 'package:deus_mobile/routes/navigation_item.dart';

class NavigationService {
  NavigationItem selectedNavItem = NavigationItem.swap;
  NavigationService({
    this.selectedNavItem,
  });

  bool isSelected(NavigationItem item) => selectedNavItem == item;
}
