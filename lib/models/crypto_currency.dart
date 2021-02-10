import 'package:deus/models/token.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/widgets/svg.dart';

//TODO (@CodingDavid8) Refactor and rename into Token etc.
class CryptoCurrency extends Token {
  const CryptoCurrency({
    @required String name,
    @required String shortName,
    String logoPath,
  }) : super(name, shortName, logoPath);
}

extension PathCheck on String {
  bool get isSvg => this.endsWith('.svg');

  Widget showImage({double size}) =>
      isSvg ? PlatformSvg.asset(this, height: size, width: size) : Image.asset(this, height: size, width: size);
}
