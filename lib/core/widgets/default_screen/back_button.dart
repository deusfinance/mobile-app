import '../../../routes/navigation_service.dart';
import 'package:flutter/material.dart';

import '../../../statics/styles.dart';

import '../../../locator.dart';

class BackButtonWithText extends StatelessWidget {
  final VoidCallback? onPressed;
  const BackButtonWithText({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          this.onPressed ?? () => locator<NavigationService>().goBack(context),
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
