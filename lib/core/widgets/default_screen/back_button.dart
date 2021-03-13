import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:flutter/material.dart';

import 'package:deus_mobile/statics/styles.dart';

import '../../../locator.dart';

class BackButtonWithText extends StatelessWidget {
  final VoidCallback onPressed;
  const BackButtonWithText({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onPressed ?? () => locator<NavigationService>().goBack(context),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios_rounded),
          const SizedBox(width: 8),
          Text('BACK', style: MyStyles.whiteMediumTextStyle)
        ],
      ),
    );
  }
}
