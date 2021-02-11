import 'package:flutter/material.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';

import '../../screens/synthetics/synchronizer_screen.dart';
import 'filled_gradient_selection_button.dart';

class SelectionButton extends StatefulWidget {
  final String label;
  final void Function(bool selected) onPressed;
  final bool selected;

  SelectionButton({this.label, this.selected = false, this.onPressed});

  @override
  _SelectionButtonState createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {


  @override
  Widget build(BuildContext context) {
    return !widget.selected
        ? OutlineGradientButton(
            strokeWidth: 1,
            inkWell: true,
            radius: const Radius.circular(10),
            gradient: SynchronizerScreen.kGradient,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: SynchronizerScreen.kPadding),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, height: 1),
              ),
            ),
            onTap:() => widget.onPressed(widget.selected))
        : FilledGradientSelectionButton(onPressed:() => widget.onPressed(widget.selected), selected: widget.selected, label: widget.label,);
  }
}
