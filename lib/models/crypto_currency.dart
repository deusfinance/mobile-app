import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/widgets/svg.dart';


//TODO (@CodingDavid8) Refactor and rename into Token etc.
class CryptoCurrency extends Equatable {
  final String name;
  final String shortName;
  final String logoPath;
  const CryptoCurrency({
    @required this.name,
    @required this.shortName,
    this.logoPath,
  });

  @override
  List<Object> get props => [this.name, this.shortName];
}

extension PathCheck on String {
  bool get isSvg => this.endsWith('.svg');

  Widget showImage({double size}) => isSvg
      ? PlatformSvg.asset(this, height: size, width: size)
      : Image.asset(this, height: size, width: size);
}
