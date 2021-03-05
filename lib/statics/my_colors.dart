import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class MyColors {

  static MaterialColor background = _getMaterialColor(0, 0, 0, 0xFF000000);

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

  static MaterialColor White = _getMaterialColor(208, 208, 208, 0xFFFFFFFF);
  static MaterialColor HalfWhite = _getMaterialColor(255, 255, 255, 0xAAFFFFFF);
  static MaterialColor Black = _getMaterialColor(0, 0, 0, 0xFF000000);
  static MaterialColor HalfBlack = _getMaterialColor(0, 0, 0, 0xFF000000);
  static MaterialColor Main_BG_Black = _getMaterialColor(13, 13, 13, 0xFF0D0D0D);
  static MaterialColor Gray = _getMaterialColor(44, 44, 44, 0xFF2C2C2C);
  static MaterialColor Button_BG_Black = _getMaterialColor(28, 28, 28, 0xFF1C1C1C);
  static MaterialColor Blue = _getMaterialColor(7, 121, 228, 0xFF0779E4);
  static MaterialColor Purple = _getMaterialColor(234, 44, 98, 0xFFEA2C62);
  static MaterialColor Cyan = _getMaterialColor(21, 43, 27, 0xFF152b1b);
  static MaterialColor Green = _getMaterialColor(196, 235, 137, 0xFFC4EB89);
  static MaterialColor Blue_Gr =_getMaterialColor(94, 196, 214, 0xFF5EC4D6);
  static MaterialColor ToastGreen = _getMaterialColor(0, 209, 108, 0xFF00D16C);
  static MaterialColor ToastGrey = _getMaterialColor(196, 196, 196, 0xFFC4C4C4);





//  static const White = 0xFFFFFFFF;
//  static const HalfWhite = 0xAAFFFFFF;
//  static const Black = 0xFF000000;
//  static const HalfBlack = 0xAA1C1C1C;
//  static const Main_BG_Black = 0xFF0D0D0D;
//  static const Button_BG_Black = 0xFF1C1C1C;
//  static const Blue = 0xFF0779E4;
//  static const Purple = 0xFFEA2C62;
//  static const Cyan = 0xFF152b1b;
//  static const Green = 0xFFC4EB89;
//  static const Blue_Gr = 0xFF5EC4D6;
  /// color of approved toast container
  // static const ToastGreen = 0xFF00D16C;
  // /// color of pending toast container
  // static const ToastGrey = 0xFFC4C4C4;
  static const Background = 0xFF0D0D0D;
  static const kAddressBackground = 0xFF61C0BF;
//  static const ToastGreen = 0xFF00D16C;
//  /// color of pending toast container
//  static const ToastGrey = 0xFFC4C4C4;
//  static const Background = 0xFF0D0D0D;


  static const blueToGreenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [const Color(0xFF0779E4), const Color(0xFF1DD3BD)],
  );

  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [const Color(0xFF57587D),const Color(0xFF637EA1),  const Color(0xFF637EA1),  const Color(0xFF534C72),],
  );

  static var blueToPurpleGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Blue, Purple],
  );

  static var greenToBlueGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Green, Blue_Gr],
  );
}
