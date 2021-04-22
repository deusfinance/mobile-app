import 'package:deus_mobile/models/synthetics/sign.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contract_input_data.g.dart';

@JsonSerializable(nullable: true)
class ContractInputData{
  int multiplier;
  Map<String, Sign> signs;
  String price;
  int fee;
  int blockNo;


  ContractInputData();

  factory ContractInputData.fromJson(Map<String, dynamic> json) => _$ContractInputDataFromJson(json);
  Map<String, dynamic> toJson() => _$ContractInputDataToJson(this);

  BigInt getPrice(){
    return BigInt.parse(price);
  }

  getBlockNo(){
    return BigInt.from(blockNo);
  }

  getFee(){
    return BigInt.from(fee);
  }

  getMultiplier(){
    return BigInt.from(multiplier);
  }
}