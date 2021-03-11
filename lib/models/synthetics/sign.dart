
import 'package:json_annotation/json_annotation.dart';

part 'sign.g.dart';

@JsonSerializable(nullable: true)
class Sign {
  int v;
  String r;
  String s;

  Sign(this.v, this.r, this.s);

  factory Sign.fromJson(Map<String, dynamic> json) => _$SignFromJson(json);
  Map<String, dynamic> toJson() => _$SignToJson(this);
  
}
