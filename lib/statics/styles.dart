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

//  decorations
  static var lightBlackBorderDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Color(MyColors.Button_BG_Black),
      border: Border.all(color: Color(MyColors.HalfBlack), width: 1.0));
  static var darkWithBorderDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Color(MyColors.Button_BG_Black),
      border: Border.all(color: Color(MyColors.Black), width: 1.0));

  static var darkWithNoBorderDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Color(MyColors.Button_BG_Black));

  static var blueToPurpleDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      gradient: MyColors.blueToPurpleGradient);

  static var greenToBlueDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      gradient: MyColors.greenToBlueGradient);

//  text styles
  static var lightWhiteSmallTextStyle = TextStyle(
    fontFamily: "Monument",
    fontWeight: FontWeight.w300,
    fontSize: S6,
    color: Color(MyColors.HalfWhite),
  );
  static var lightWhiteMediumTextStyle = TextStyle(
    fontFamily: "Monument",
    fontWeight: FontWeight.w300,
    fontSize: S4,
    color: Color(MyColors.HalfWhite),
  );
  static var whiteSmallTextStyle = TextStyle(
    fontFamily: "Monument",
    fontWeight: FontWeight.w300,
    fontSize: S6,
    color: Color(MyColors.White),
  );
  static var blackSmallTextStyle = TextStyle(
    fontFamily: "Monument",
    fontWeight: FontWeight.w300,
    fontSize: S6,
    color: Color(MyColors.Black),
  );
  static var blackMediumTextStyle = TextStyle(
    fontFamily: "Monument",
    fontWeight: FontWeight.w300,
    fontSize: S4,
    color: Color(MyColors.Black),
  );
  static var whiteMediumTextStyle = TextStyle(
    fontFamily: "Monument",
    fontWeight: FontWeight.w300,
    fontSize: S4,
    color: Color(MyColors.White),
  );

  static var bottomNavBarUnSelectedStyle = TextStyle(
    fontFamily: "Monument",
    fontWeight: FontWeight.w300,
    fontSize: S5,
    color: Color(MyColors.White),
  );
}
