import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final VoidCallback onClosed;
  final Color color;

  Toast({this.label, this.onPressed, this.color, this.onClosed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
            color: color),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: MyStyles.whiteMediumTextStyle,
                ),
                Spacer(),
                GestureDetector(onTap: onClosed, child: Icon(Icons.close))
              ],
            ),
            Row(
              children: [
                Text(
                  'Approved sDEA spend',
                  style: MyStyles.whiteMediumUnderlinedTextStyle,
                ),
                Transform.rotate(
                  angle: 150,
                  child: Icon(Icons.arrow_right_alt_outlined),
                )
              ],
            )
          ],
        ),
      ),
    );
    ;
  }
}
