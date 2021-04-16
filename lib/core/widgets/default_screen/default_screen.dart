import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:flutter/material.dart';

import '../../../statics/my_colors.dart';
import 'will_pop_dialog.dart';
import 'bottom_nav_bar.dart';
import 'custom_app_bar.dart';
import 'header_with_address.dart';

class DefaultScreen extends StatelessWidget {
  final Widget child;
  final bool showHeading;

  const DefaultScreen({Key key, @required this.child, this.showHeading = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (!locator<NavigationService>().canGoBack(context))
            return await showWillPopDialog(context);
          else
            return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: MyColors.Main_BG_Black,
          appBar: showHeading ? CustomAppBar() : null,
          body: Column(
            children: [
              // const SizedBox(height: 50),
              //TODO: Move into AppBar?
              if (showHeading) Container(margin: EdgeInsets.only(right: 8, left: 8), child: HeaderWithAddress()),
              Expanded(child: child),
            ],
          ),
          bottomNavigationBar: MyBottomNavBar(),
        ));
  }
}
