import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'sign.g.dart';

@JsonSerializable()
class Sign {
  int v;
  String r;
  String s;

  Sign(this.v, this.r, this.s);

  factory Sign.fromJson(Map<String, dynamic> json) => _$SignFromJson(json);
  Map<String, dynamic> toJson() => _$SignToJson(this);

  BigInt getV() {
    return BigInt.from(v);
  }

  Uint8List getR() {
    final List<int> list = [];
    for (int i = 2; i <= r.length - 2; i += 2) {
      final hex = r.substring(i, i + 2);

      final number = int.parse(hex, radix: 16);
      list.add(number);
    }
    return Uint8List.fromList(list);
  }

  Uint8List getS() {
    final List<int> list = [];
    for (int i = 2; i <= s.length - 2; i += 2) {
      final hex = s.substring(i, i + 2);

      final number = int.parse(hex, radix: 16);
      list.add(number);
    }
    return Uint8List.fromList(list);
  }
}
