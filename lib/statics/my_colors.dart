import 'package:flutter/cupertino.dart';

class MyColors {
  static const White = 0xFFFFFFFF;
  static const HalfWhite = 0x88FFFFFF;
  static const Black = 0xFF000000;
  static const HalfBlack = 0x881C1C1C;
  static const Main_BG_Black = 0xFF0D0D0D;
  static const Button_BG_Black = 0xFF1C1C1C;
  static const Blue = 0xFF0779E4;
  static const Purple = 0xFFEA2C62;
  static const Cyan = 0xFF152b1b;
  static const Green = 0xFFC4EB89;
  static const Blue_Gr = 0xFF5EC4D6;
  static const ToastGreen = 0xFF00D16C;
  static const ToastGrey = 0xFFC4C4C4;
  static const Background = 0xFF0D0D0D;


  static const blueToGreenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [const Color(0xFF0779E4), const Color(0xFF1DD3BD)],
  );

  static const blueToPurpleGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [const Color(Blue), const Color(Purple)],
  );

  static const greenToBlueGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [const Color(Green), const Color(Blue_Gr)],
  );
}
