import 'package:deus_mobile/statics/my_colors.dart';
import 'package:flutter/material.dart';

import 'back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  ///If a leading is passed, this will be shown in the upper left corner of the AppBar.
  ///
  ///If leading is null and the user can go back, a back button is displayed. 
  ///Otherwise, there will be no leading.
  final Widget? leading;

  const CustomAppBar({Key? key, this.title, this.leading}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      leading: leading != null ? BackButtonWithText() : Navigator.canPop(context) ? BackButtonWithText() : Container(),
      // leading: leading != null ? BackButtonWithText() : Container(),
      backgroundColor: Color(MyColors.Background).withOpacity(1),
      centerTitle: true,
      title: title != null ? Text(title!, style: TextStyle(fontSize: 25)) : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
