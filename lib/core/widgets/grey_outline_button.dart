///TODO (@CodingDavid8): Clean up buttons and put them in core/widgets/buttons/
import 'package:flutter/material.dart';

class GreyOutlineButton extends StatelessWidget {
  final darkGrey = Color(0xFF1C1C1C);

  final label;
  final onPressed;

  GreyOutlineButton({this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
            color: darkGrey, borderRadius: BorderRadius.circular(10)),
        child: OutlineButton(
          highlightedBorderColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.transparent,
          borderSide: BorderSide(color: Colors.black),
          child: Text(
            label,
            style: TextStyle(fontSize: 20),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
