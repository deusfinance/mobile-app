import 'package:flutter/material.dart';

import '../../screens/synthetics/synchronizer_screen.dart';

class FilledGradientSelectionButton extends StatelessWidget {
  final bool selected;
  final Function onPressed;
  final String label;
  final LinearGradient gradient;

  FilledGradientSelectionButton({this.selected, this.onPressed, this.label, this.gradient = SynchronizerScreen.kGradient});


  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(gradient: this.gradient, borderRadius: BorderRadius.circular(10)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: this.onPressed,
            borderRadius: BorderRadius.circular(10.0),
            splashColor: Colors.grey[500],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: SynchronizerScreen.kPadding*2),
                child: Text(
                  this.label,
                  style: const  TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      height: 1
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
