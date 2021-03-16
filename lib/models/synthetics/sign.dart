
import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:web3dart/web3dart.dart';

part 'sign.g.dart';

@JsonSerializable(nullable: true)
class Sign {
  int v;
  String r;
  String s;

  Sign(this.v, this.r, this.s);

  factory Sign.fromJson(Map<String, dynamic> json) => _$SignFromJson(json);
  Map<String, dynamic> toJson() => _$SignToJson(this);

  getV(){
    return BigInt.from(v);
  }
  getR(){
    List<int> list = [];
    for (int i = 2; i <= r.length - 2; i += 2) {
      final hex = r.substring(i, i + 2);

      final number = int.parse(hex, radix: 16);
      list.add(number);
    }
    return Uint8List.fromList(list);
  }
  getS(){
    List<int> list = [];
    for (int i = 2; i <= s.length - 2; i += 2) {
      final hex = s.substring(i, i + 2);

      final number = int.parse(hex, radix: 16);
      list.add(number);
    }
    return Uint8List.fromList(list);
  }
  
}
