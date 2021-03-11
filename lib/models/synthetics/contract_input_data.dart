import 'package:deus_mobile/models/synthetics/sign.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contract_input_data.g.dart';

@JsonSerializable(nullable: true)
class ContractInputData{
  List<Sign> signs;
  double price;
  int fee;
  int blockNo;


  ContractInputData();

  factory ContractInputData.fromJson(Map<String, dynamic> json) => _$ContractInputDataFromJson(json);
  Map<String, dynamic> toJson() => _$ContractInputDataToJson(this);
}