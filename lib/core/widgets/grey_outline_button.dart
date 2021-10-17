import '../../statics/styles.dart';

///TODO (@CodingDavid8): Clean up buttons and put them in core/widgets/buttons/
import 'package:flutter/material.dart';

class GreyOutlineButton extends StatelessWidget {
  final darkGrey = const Color(0xFF1C1C1C);

  final String label;
  final Function? onPressed;

  GreyOutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
            color: darkGrey,
            borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            // highlightedBorderColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
            // color: Colors.transparent,
            // borderSide: const BorderSide(color: Colors.black),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
          onPressed: () => onPressed!,
        ),
      ),
    );
  }
}
