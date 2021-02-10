import 'package:flutter/material.dart';

/// Colors of the project
//TODO (@CodingDavid8): Refactor into my_colors.dart.
abstract class MyColors {
  ///0xFFFFFFFF
  static const Color primary = Color(0xFFFFFFFF);
  static MaterialColor primaryMC = _getMaterialColor(
      primary.red, primary.green, primary.blue, primary.value);

  ///0xFF000000
  static MaterialColor background = _getMaterialColor(0, 0, 0, 0xFF000000);

  ///00FFC8
  static MaterialColor accent = _getMaterialColor(0, 255, 200, 0xFF00FFC8);
  static MaterialColor secondary = _getMaterialColor(36, 182, 183, 0xFF24B6B7);

  static MaterialColor footer = _getMaterialColor(0, 0, 0, 0xFF000000);

  static Color disabled = Colors.grey.withOpacity(0.2);

  static MaterialColor grey = _getMaterialColor(178, 178, 178, 0xFFB2B2B2);

  ///0xFFFFFFFF
  static MaterialColor onAccentText =
      _getMaterialColor(255, 255, 255, 0xFFFFFFFF);

  ///0xFFF5F5F5
  static MaterialColor dividerGrey =
      _getMaterialColor(245, 245, 245, 0xFFF5F5F5);

  ///0xFFFAFAFA
  static MaterialColor highlightedBackground =
      _getMaterialColor(250, 250, 250, 0xFFFAFAFA);

  ///0xFFF0F0F0
  static MaterialColor loadingBase =
      _getMaterialColor(240, 240, 240, 0xFFF0F0F0);

  static MaterialColor brightLoading =
      _getMaterialColor(250, 250, 250, 0xFFFAFAFA);

  static MaterialColor error = _getMaterialColor(204, 66, 41, 0xFFCC4229);

  ///0xFFBFBFBF
  static MaterialColor disabledButton =
      _getMaterialColor(191, 191, 191, 0xFFBFBFBF);

  static MaterialColor red = Colors.red;

  static MaterialColor _getMaterialColor(int r, int g, int b, var hex) {
    final Map<int, Color> data = {
      50: Color.fromRGBO(r, g, b, 0.1),
      100: Color.fromRGBO(r, g, b, 0.2),
      200: Color.fromRGBO(r, g, b, 0.3),
      300: Color.fromRGBO(r, g, b, 0.4),
      400: Color.fromRGBO(r, g, b, 0.5),
      500: Color.fromRGBO(r, g, b, 0.6),
      600: Color.fromRGBO(r, g, b, 0.7),
      700: Color.fromRGBO(r, g, b, 0.8),
      800: Color.fromRGBO(r, g, b, 0.9),
      900: Color.fromRGBO(r, g, b, 1.0),
    };
    return MaterialColor(hex, data);
  }
}
