// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_input_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractInputData _$ContractInputDataFromJson(Map<String, dynamic> json) {
  return ContractInputData(
    json['multiplier'] as int,
    (json['signs'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, Sign.fromJson(e as Map<String, dynamic>)),
    ),
    json['price'] as String,
    json['fee'] as int,
    json['blockNo'] as int,
  );
}

Map<String, dynamic> _$ContractInputDataToJson(ContractInputData instance) =>
    <String, dynamic>{
      'multiplier': instance.multiplier,
      'signs': instance.signs,
      'price': instance.price,
      'fee': instance.fee,
      'blockNo': instance.blockNo,
    };
