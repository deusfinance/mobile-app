import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

class Steps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 75),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              '1',
              style: MyStyles.whiteMediumTextStyle,
            ),
            decoration:
            BoxDecoration(gradient: MyColors.blueToGreenGradient, shape: BoxShape.circle),
          ),
          Expanded(
              child: Container(
                  height: 3, decoration: BoxDecoration(gradient: MyColors.blueToGreenGradient))),
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              '2',
              style: MyStyles.whiteMediumTextStyle,
            ),
            decoration: BoxDecoration(
                color: Color(MyColors.Button_BG_Black), shape: BoxShape.circle),
          )
        ],
      ),
    );
  }
}
