import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'stock.g.dart';

@JsonSerializable(nullable: true)
class Stock{
  String name;
  String sector;
  String symbol;
  @JsonKey(name: "short_name")
  String shortName;
  @JsonKey(name: "short_symbol")
  String shortSymbol;
  @JsonKey(name: "long_name")
  String longName;
  @JsonKey(name: "long_symbol")
  String longSymbol;
  String logo;

  Stock();

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
  Map<String, dynamic> toJson() => _$StockToJson(this);

  String getLogo(){
    return logo;
  }
}