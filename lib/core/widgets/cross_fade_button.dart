import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/screens/stake_screen/stake_screen.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

import 'filled_gradient_selection_button.dart';

class CrossFadeButton extends StatelessWidget {
  final VoidCallback mergedButtonOnPressed;
  final VoidCallback approveOnPressed;

  final String mergedButtonLabel;
  final String offButtonLabel;

  /// if true shows both button, if false shows just one
  final ButtonStates buttonState;

  CrossFadeButton(
      {this.mergedButtonOnPressed,
      this.approveOnPressed,
      this.buttonState,
      this.mergedButtonLabel,
      this.offButtonLabel});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: Row(
          children: [
            Expanded(
              child: FilledGradientSelectionButton(
                onPressed: approveOnPressed,
                label: 'APPROVE',
                textStyle: MyStyles.blackMediumTextStyle,
                gradient: MyColors.blueToGreenGradient,
              ),
            ),
            if (buttonState != ButtonStates.isApproved)
              SizedBox(
                width: 10,
              ),
            Expanded(
              child: SizedBox(
                child: SelectionButton(
                  gradient: MyColors.blueToGreenGradient,
                  child: buttonState == ButtonStates.pendingApprove
                      ? SizedBox(
                          height: 21,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                  onPressed: approveOnPressed,
                  label: offButtonLabel,
                  selected: false,
                  textStyle: buttonState == ButtonStates.isApproved
                      ? MyStyles.blackMediumTextStyle
                      : MyStyles.lightWhiteMediumTextStyle,
                ),
              ),
            )
          ],
        ),
        secondChild: SizedBox(
          width: double.infinity,
          child: SelectionButton(
              gradient: MyColors.blueToGreenGradient,
              onPressed: mergedButtonOnPressed,
              label: mergedButtonLabel,
              selected: true,
              textStyle: MyStyles.blackMediumTextStyle),
        ),
        crossFadeState: buttonState == ButtonStates.isApproved
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 150));
  }
}
