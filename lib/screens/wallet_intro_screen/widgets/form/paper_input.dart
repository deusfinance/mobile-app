import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaperInput extends StatelessWidget {
  PaperInput(
      {this.labelText,
      this.hintText,
      this.errorText,
      this.onChanged,
      this.controller,
      this.maxLines,
      this.obscureText = false,
      this.textStyle,
      this.inputFormatters,
      this.keyboardType});

  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final bool? obscureText;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  final TextEditingController? controller;
  final TextStyle? textStyle;

  final Color borderColor = const Color(0xFF282828);

  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(color: Color(0xFF282828)),
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
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        hintText: this.hintText,
        errorText: this.errorText,
      ),
    );
  }
}
