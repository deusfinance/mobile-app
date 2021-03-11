// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sign _$SignFromJson(Map<String, dynamic> json) {
  return Sign(
    json['v'] as int,
    json['r'] as String,
    json['s'] as String,
  );
}

Map<String, dynamic> _$SignToJson(Sign instance) => <String, dynamic>{
      'v': instance.v,
      'r': instance.r,
      's': instance.s,
    };
