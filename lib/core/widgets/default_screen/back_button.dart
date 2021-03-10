import 'package:flutter/material.dart';

import 'package:deus_mobile/statics/styles.dart';

class BackButtonWithText extends StatelessWidget {
  final VoidCallback onPressed;
  const BackButtonWithText({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onPressed ?? () => Navigator.pop(context),
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
