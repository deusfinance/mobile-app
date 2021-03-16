import 'dart:math';

import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_state.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
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

  String shortBalance = "0";
  String longBalance = "0";
  String shortAllowances = "0";
  String longAllowances = "0";
  //Mode is Long or Short
  Mode mode;

  BigInt getBalance() {
    if(mode == Mode.LONG)
      return EthereumService.getWei(longBalance??"0");
    else if (mode == Mode.SHORT)
      return EthereumService.getWei(shortBalance??"0");
    return null;
  }

  BigInt getAllowances() {
    if(mode == Mode.LONG)
      return EthereumService.getWei(longAllowances??"0");
    else if (mode == Mode.SHORT)
      return EthereumService.getWei(shortAllowances??"0");
    return null;
  }


  Stock(String name, String symbol, String logo)
      : super(name, symbol, logo){
        this.name = name;
        this.symbol = symbol;
        this.logo = logo;
  this.mode = Mode.LONG;
  }

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
  Map<String, dynamic> toJson() => _$StockToJson(this);

  String getLogo() {
    return logo;
  }
}
