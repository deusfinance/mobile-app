// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GWei.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GWei _$GWeiFromJson(Map<String, dynamic> json) {
  return GWei()
    ..slow = (json['safeLow'] as num)?.toDouble()
    ..average = (json['average'] as num)?.toDouble()
    ..fast = (json['fast'] as num)?.toDouble();
}

Map<String, dynamic> _$GWeiToJson(GWei instance) => <String, dynamic>{
  'safeLow': instance.slow,
  'average': instance.average,
  'fast': instance.fast,
};