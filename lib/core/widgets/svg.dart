import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PlatformSvg {
  ///Display SVG Image.
  ///assetName is /assets/assets/$assetName on Web.
  static Widget asset(String assetName,
      {double width,
      double height,
      BoxFit fit = BoxFit.contain,
      Color color,
      Alignment alignment = Alignment.center,
      String semanticsLabel}) {
    if (kIsWeb) {
      return Image.network('/assets/assets/$assetName',
          width: width,
          height: height,
          fit: fit,
          color: color,
          alignment: alignment,
          semanticLabel: semanticsLabel);
    }
    return SvgPicture.asset('assets/$assetName',
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment,
        semanticsLabel: semanticsLabel);
  }
}
