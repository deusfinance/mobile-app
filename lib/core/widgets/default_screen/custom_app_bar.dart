import 'package:deus_mobile/statics/my_colors.dart';
import 'package:flutter/material.dart';

import 'back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget leading;

  const CustomAppBar({Key key, this.title, this.leading}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      leading: leading ?? BackButtonWithText(),
      backgroundColor: Color(MyColors.Background).withOpacity(1),
      centerTitle: true,
      title: title != null ? Text(title, style: TextStyle(fontSize: 25)) : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
