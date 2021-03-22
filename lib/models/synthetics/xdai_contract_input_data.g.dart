// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xdai_contract_input_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XDaiContractInputData _$XDaiContractInputDataFromJson(
    Map<String, dynamic> json) {
  return XDaiContractInputData()
    ..multiplier = json['multiplier'] as int
    ..signs = (json['signs'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Sign.fromJson(e as Map<String, dynamic>)),
    )
    ..price = json['price'] as String
    ..fee = json['fee'] as int
    ..blockNo = json['blockNo'] as int;
}

Map<String, dynamic> _$XDaiContractInputDataToJson(
        XDaiContractInputData instance) =>
    <String, dynamic>{
      'multiplier': instance.multiplier,
      'signs': instance.signs,
      'price': instance.price,
      'fee': instance.fee,
      'blockNo': instance.blockNo,
    };
