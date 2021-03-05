import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

class DisabledButton extends StatelessWidget {
  final Widget child;
  final String label;

  DisabledButton({this.child, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MyStyles.darkWithBorderDecoration,
      padding: EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.center,
        child: child ??
            Text(
              label,
              style: MyStyles.lightWhiteMediumTextStyle,
            ),
      ),
    );
  }
}
