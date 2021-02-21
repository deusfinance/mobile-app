import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

class BackButtonWithText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, //TODO: nach verknüpfung back logik hinzufügen
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios_rounded,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            'BACK',
            style: MyStyles.whiteMediumTextStyle,
          )
        ],
      ),
    );
  }
}
