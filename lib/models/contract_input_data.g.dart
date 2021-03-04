// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_input_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractInputData _$ContractInputDataFromJson(Map<String, dynamic> json) {
  return ContractInputData()
    ..signs = (json['signs'] as List)
        ?.map(
            (e) => e == null ? null : Sign.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..price = (json['price'] as num)?.toDouble()
    ..fee = json['fee'] as int
    ..blockNo = json['blockNo'] as int;
}

Map<String, dynamic> _$ContractInputDataToJson(ContractInputData instance) =>
    <String, dynamic>{
      'signs': instance.signs,
      'price': instance.price,
      'fee': instance.fee,
      'blockNo': instance.blockNo,
    };
