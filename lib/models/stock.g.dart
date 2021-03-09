// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stock _$StockFromJson(Map<String, dynamic> json) {
  return Stock(
    json['name'] as String,
    json['symbol'] as String,
    json['logo'] as String,
  )
    ..balance = json['balance'] as String
    ..allowances = json['allowances'] as String
    ..chainId = json['chainId'] as int
    ..sector = json['sector'] as String
    ..shortName = json['short_name'] as String
    ..shortSymbol = json['short_symbol'] as String
    ..longName = json['long_name'] as String
    ..longSymbol = json['long_symbol'] as String;
}

Map<String, dynamic> _$StockToJson(Stock instance) => <String, dynamic>{
      'balance': instance.balance,
      'allowances': instance.allowances,
      'chainId': instance.chainId,
      'name': instance.name,
      'sector': instance.sector,
      'symbol': instance.symbol,
      'short_name': instance.shortName,
      'short_symbol': instance.shortSymbol,
      'long_name': instance.longName,
      'long_symbol': instance.longSymbol,
      'logo': instance.logo,
    };
