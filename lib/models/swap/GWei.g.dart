// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GWei.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GWei _$GWeiFromJson(Map<String, dynamic> json) {
  return GWei()
    ..slow = (json['slow'] as num)?.toDouble()
    ..average = (json['standard'] as num)?.toDouble()
    ..fast = (json['fast'] as num)?.toDouble();
}

Map<String, dynamic> _$GWeiToJson(GWei instance) => <String, dynamic>{
  'slow': instance.slow,
  'standard': instance.average,
  'fast': instance.fast,
};
