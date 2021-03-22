// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_price_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockPriceDetail _$StockPriceDetailFromJson(Map<String, dynamic> json) {
  return StockPriceDetail(
    (json['price'] as num)?.toDouble(),
    (json['fee'] as num)?.toDouble(),
    json['is_close'] as bool,
  );
}

Map<String, dynamic> _$StockPriceDetailToJson(StockPriceDetail instance) =>
    <String, dynamic>{
      'price': instance.price,
      'fee': instance.fee,
      'is_close': instance.isClosed,
    };
