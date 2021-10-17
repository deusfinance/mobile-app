import '../../statics/my_colors.dart';
import '../../statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWithMax extends StatelessWidget {
  final TextEditingController controller;

  /// the maximum value that can be chosen
  final double maxValue;
  final TextInputType keyboardType;
  final String hintText;

  TextFieldWithMax(
      {required this.controller,
      required this.maxValue,
      this.keyboardType = TextInputType.number,
      this.hintText = '0.00'});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
          color: MyColors.Button_BG_Black,
          border: Border.all(color: Colors.white.withOpacity(0.1))),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        keyboardType: keyboardType,
        cursorColor: Colors.white,
        autofocus: false,
        maxLines: 1,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              new RegExp(r'([0-9]+([.][0-9]*)?|[.][0-9]+)'))
        ],
        controller: controller,
        style: MyStyles.lightWhiteMediumTextStyle,
        decoration: InputDecoration(
            hintText: hintText,
            focusedErrorBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: InkWell(
              onTap: () {
                controller.text = maxValue.toString();
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Text(
                  'MAX',
                  style: MyStyles.whiteSmallTextStyle,
                ),
                decoration: BoxDecoration(
                    color: const Color(0xFF5BCCBD).withOpacity(0.25),
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(7)),
              ),
            )),
      ),
    );
  }
}
