import 'package:deus_mobile/models/synthetics/sign.dart';
import 'package:json_annotation/json_annotation.dart';

part 'xdai_contract_input_data.g.dart';

@JsonSerializable(nullable: true)
class XDaiContractInputData{
  int multiplier;
  Map<String, Sign> signs;
  String price;
  int fee;
  int blockNo;


  XDaiContractInputData();

  factory XDaiContractInputData.fromJson(Map<String, dynamic> json) => _$XDaiContractInputDataFromJson(json);
  Map<String, dynamic> toJson() => _$XDaiContractInputDataToJson(this);

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