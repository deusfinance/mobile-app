import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

import 'filled_gradient_selection_button.dart';

class SelectionButton extends StatefulWidget {
  final String? label;
  final void Function(bool selected)? onPressed;
  final bool selected;
  final LinearGradient? gradient;
  TextStyle? textStyle;

  /// You can choose between using a label or another widget if you use a widget the label is useless
  final Widget? child;

  SelectionButton(
      {this.label,
      this.selected = false,
      this.onPressed,
      this.gradient,
      this.child,
      this.textStyle}){
    if(this.textStyle == null){
      this.textStyle = MyStyles.whiteMediumTextStyle;
    }
  }

  @override
  _SelectionButtonState createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {
  @override
  Widget build(BuildContext context) {
    return !widget.selected
        ? InkWell(
            onTap: () {
              widget.onPressed!(widget.selected);
            },
            child: Container(
              decoration: MyStyles.darkWithBorderDecoration,
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.center,
                child: widget.child ?? Text(
                  widget.label!,
                  style: MyStyles.lightWhiteMediumTextStyle,
                ),
              ),
            ),
          )
        : FilledGradientSelectionButton(
            onPressed: () => widget.onPressed!(widget.selected),
            selected: widget.selected,
            label: widget.label!,
            gradient: widget.gradient!,
            textStyle: widget.textStyle!,
          );
  }

//  OutlineGradientButton(
//            strokeWidth: 1,
//            inkWell: true,
//            radius: const Radius.circular(MyStyles.cardRadiusSize),
////            TODO (@kazem) make it not gradient
//            gradient: SynchronizerScreen.kGradient,
//            child: Padding(
//              padding: const EdgeInsets.symmetric(
//                  vertical: MyStyles.mainPadding),
//              child: Text(
//                widget.label,
//                textAlign: TextAlign.center,
//                style: MyStyles.lightWhiteMediumTextStyle,
//              ),
//            ),
//            onTap:() => widget.onPressed(widget.selected))
}
