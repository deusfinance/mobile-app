// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockAddress _$StockAddressFromJson(Map<String, dynamic> json) {
  return StockAddress(
    json['id'] as String,
    json['long'] as String,
    json['short'] as String,
  );
}

Map<String, dynamic> _$StockAddressToJson(StockAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'long': instance.long,
      'short': instance.short,
    };
