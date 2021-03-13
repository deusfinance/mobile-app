import 'package:deus_mobile/statics/my_colors.dart';
import 'package:flutter/material.dart';




class KeyValueString extends StatelessWidget {
  final String keyStr;
  final String valueStr;
  final Color keyColor;
  final Color valueColor;
  final Widget valueSuffix;
  const KeyValueString(
    this.keyStr,
    this.valueStr, {
    this.keyColor = MyColors.primary,
    this.valueColor = MyColors.primary,
    Key flutterKey,
    this.valueSuffix,
  }) : super(key: flutterKey);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(keyStr, style: TextStyle(color: keyColor, height: 1.5)),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(valueStr, style: TextStyle(color: valueColor, height: 1.5)),
          if (valueSuffix != null) valueSuffix
        ])
      ],
    );
  }
}
