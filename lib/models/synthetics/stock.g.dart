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
    ..sector = json['sector'] as String
    ..shortName = json['short_name'] as String
    ..shortSymbol = json['short_symbol'] as String
    ..longName = json['long_name'] as String
    ..longSymbol = json['long_symbol'] as String
    ..shortBalance = json['shortBalance'] as String
    ..longBalance = json['longBalance'] as String
    ..shortAllowances = json['shortAllowances'] as String
    ..longAllowances = json['longAllowances'] as String
    ..mode = _$enumDecodeNullable(_$ModeEnumMap, json['mode']);
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
      'shortBalance': instance.shortBalance,
      'longBalance': instance.longBalance,
      'shortAllowances': instance.shortAllowances,
      'longAllowances': instance.longAllowances,
      'mode': _$ModeEnumMap[instance.mode],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ModeEnumMap = {
  Mode.LONG: 'LONG',
  Mode.SHORT: 'SHORT',
};
