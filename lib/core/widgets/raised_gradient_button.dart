import 'package:deus_mobile/statics/styles.dart';
///TODO (@CodingDavid8): Clean up buttons and put them in core/widgets/buttons/
import 'package:flutter/material.dart';

class RaisedGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final gradient;

  RaisedGradientButton({this.label, this.onPressed, @required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            gradient: gradient, borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
        height: 55,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
          color: Colors.transparent,
          child: Text(
            label,
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
