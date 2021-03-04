import 'dart:ui';

import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

class DarkButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final TextStyle labelStyle;

  const DarkButton({this.onPressed, this.label, this.labelStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
        child: Material(
          color: Color(MyColors.Button_BG_Black),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
            splashColor: Colors.grey[600],
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(label, style: labelStyle),
              ),
            ),
          ),
        ));
  }
}
