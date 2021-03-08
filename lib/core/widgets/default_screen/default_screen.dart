import 'package:flutter/material.dart';

import '../../../statics/my_colors.dart';
import 'bottom_nav_bar.dart';
import 'custom_app_bar.dart';
import 'header_with_address.dart';

class DefaultScreen extends StatelessWidget {
  final Widget child;

  const DefaultScreen({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.Main_BG_Black,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 50),
          //TODO: Move into AppBar
          Container(margin: EdgeInsets.only(right: 8, left: 8), child: HeaderWithAddress()),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }
}
