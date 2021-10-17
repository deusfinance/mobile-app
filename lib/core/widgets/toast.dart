import '../../statics/styles.dart';
import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  final String? label;
  final String? message;
  final VoidCallback? onPressed;
  final VoidCallback? onClosed;
  final Color? color;

  Toast({this.label, this.onPressed, this.color, this.onClosed, this.message});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
            color: color),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  label!,
                  style: MyStyles.whiteSmallTextStyle,
                ),
                const Spacer(),
                InkWell(onTap: onClosed, child: const Icon(Icons.close))
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: Text(
                    message!,
                    overflow: TextOverflow.ellipsis,
                    style: MyStyles.whiteSmallUnderlinedTextStyle,
                  ),
                ),
                Transform.rotate(
                  angle: 150,
                  child: const Icon(
                    Icons.arrow_right_alt_outlined,
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
