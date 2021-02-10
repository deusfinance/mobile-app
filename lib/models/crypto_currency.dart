import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'token.dart';

//TODO (@CodingDavid8) Refactor and rename into Token etc.
class CryptoCurrency extends Token {
  const CryptoCurrency({
    @required String name,
    @required String shortName,
    String logoPath,
  }) : super(name, shortName, logoPath);
}
