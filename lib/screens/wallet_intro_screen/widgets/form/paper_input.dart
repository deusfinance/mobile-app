import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaperInput extends StatelessWidget {
  PaperInput({
    this.labelText,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.controller,
    this.maxLines,
    this.obscureText = false,
    this.textStyle,
    this.inputFormatters,
    this.keyboardType
  });

  ValueChanged<String>? onChanged;
  String? errorText;
  String? labelText;
  String? hintText;
  bool? obscureText;
  int? maxLines;
  List<TextInputFormatter>? inputFormatters;
  TextInputType? keyboardType;

  TextEditingController? controller;
  TextStyle? textStyle;

  final Color borderColor = Color(0xFF282828);

  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(color: Color(0xFF282828)),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: this.textStyle,
      obscureText: this.obscureText!,
      controller: this.controller,
      onChanged: this.onChanged,
      maxLines: this.maxLines,
      keyboardType: this.keyboardType,
      inputFormatters: this.inputFormatters,
      decoration: InputDecoration(
        border: border,
        focusedBorder: border,
        disabledBorder: border,
        enabledBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
        labelText: this.labelText,
        labelStyle: TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        hintText: this.hintText,
        errorText: this.errorText,
      ),
    );
  }
}
