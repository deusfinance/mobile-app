import 'package:deus/statics/my_colors.dart';
import 'package:flutter/cupertino.dart';

class MyStyles {

//  font sizes
  static const S6 = 13.0;
  static const S5 = 16.0;
  static const S4 = 18.0;
  static const S3 = 20.0;
  static const S2 = 24.0;
  static const S1 = 32.0;

  static const cardRadiusSize = 12.0;
  static const mainPadding = 8.0;

  static const String kFontFamily = "Monument";


//  decorations
  static var lightBlackBorderDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(cardRadiusSize),
      color: MyColors.Button_BG_Black,
      border: Border.all(color: MyColors.HalfBlack, width: 1.0));
  static var darkWithBorderDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(cardRadiusSize),
      color: MyColors.Button_BG_Black,
      border: Border.all(color: MyColors.Black, width: 1.0));

  static var darkWithNoBorderDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(cardRadiusSize),
      color: MyColors.Button_BG_Black);

  static var blueToPurpleDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(cardRadiusSize),
      gradient: MyColors.blueToPurpleGradient);

  static var greenToBlueDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(cardRadiusSize),
      gradient: MyColors.greenToBlueGradient);

//  text styles
  static var lightWhiteSmallTextStyle = TextStyle(
    fontFamily: kFontFamily,
    fontWeight: FontWeight.w300,
    fontSize: S6,
    color: MyColors.HalfWhite,
  );
  static var lightWhiteMediumTextStyle = TextStyle(
    fontFamily: kFontFamily,
    fontWeight: FontWeight.w300,
    fontSize: S4,
    color: MyColors.HalfWhite,
  );
  static var whiteSmallTextStyle = TextStyle(
    fontFamily: kFontFamily,
    fontWeight: FontWeight.w300,
    fontSize: S6,
    color: MyColors.White,
  );
  static var blackSmallTextStyle = TextStyle(
    fontFamily: kFontFamily,
    fontWeight: FontWeight.w300,
    fontSize: S6,
    color: MyColors.Black,
  );
  static var blackMediumTextStyle = TextStyle(
    fontFamily: kFontFamily,
    fontWeight: FontWeight.w300,
    fontSize: S4,
    color: MyColors.Black,
  );
  static var whiteMediumTextStyle = TextStyle(
    fontFamily: kFontFamily,
    fontWeight: FontWeight.w300,
    fontSize: S4,
    color: MyColors.White,
  );

  static TextStyle gradientMediumTextStyle = TextStyle(
      fontFamily: kFontFamily,
      fontWeight: FontWeight.w300,
      fontSize: S4,
      foreground: Paint()
        ..shader = LinearGradient(
          colors: <Color>[Color(0xff0779E4), Color(0xff1DD3BD)],
        ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)));


  static var bottomNavBarUnSelectedStyle = TextStyle(
    fontFamily: kFontFamily,
    fontWeight: FontWeight.w300,
    fontSize: S5,
    color: MyColors.White,
  );


}

