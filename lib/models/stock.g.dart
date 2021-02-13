// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stock _$StockFromJson(Map<String, dynamic> json) {
  return Stock(
    json['name'] as String,
    json['short_name'] as String,
    json['logo'] as String,
  )
    ..sector = json['sector'] as String
    ..symbol = json['symbol'] as String
    ..shortSymbol = json['short_symbol'] as String
    ..longName = json['long_name'] as String
    ..longSymbol = json['long_symbol'] as String;
}

Map<String, dynamic> _$StockToJson(Stock instance) => <String, dynamic>{
      'name': instance.name,
      'sector': instance.sector,
      'symbol': instance.symbol,
      'short_name': instance.shortName,
      'short_symbol': instance.shortSymbol,
      'long_name': instance.longName,
      'long_symbol': instance.longSymbol,
      'logo': instance.logo,
    };
