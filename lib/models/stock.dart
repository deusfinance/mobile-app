import 'dart:math';

import 'package:deus/models/token.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock.g.dart';

@JsonSerializable(nullable: true)
class Stock extends Token {
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

  Stock(String name, String symbol, String logo)
      : this.name = name,
        this.symbol = symbol,
        this.logo = logo,
        super(name, symbol, logo);

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
  Map<String, dynamic> toJson() => _$StockToJson(this);

  String getLogo() {
    return logo;
  }
}
