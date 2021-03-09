import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  final String label;
  final String message;
  final VoidCallback onPressed;
  final VoidCallback onClosed;
  final Color color;

  Toast({this.label, this.onPressed, this.color, this.onClosed, this.message});

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: MyStyles.whiteSmallTextStyle,
                ),
                Spacer(),
                GestureDetector(onTap: onClosed, child: Icon(Icons.close))
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: MyStyles.whiteSmallTextStyle,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Transform.rotate(
                angle: 150,
                child: Icon(Icons.arrow_right_alt_outlined),
              ),
            )

          ],
        ),
      ),
    );
    ;
  }
}
