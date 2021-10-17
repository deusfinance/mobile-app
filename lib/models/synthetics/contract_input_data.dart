import 'sign.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contract_input_data.g.dart';

@JsonSerializable()
class ContractInputData {
  int multiplier;
  Map<String, Sign> signs;
  String price;
  int fee;
  int blockNo;

  ContractInputData(
      this.multiplier, this.signs, this.price, this.fee, this.blockNo);

  factory ContractInputData.fromJson(Map<String, dynamic> json) =>
      _$ContractInputDataFromJson(json);
  Map<String, dynamic> toJson() => _$ContractInputDataToJson(this);

  BigInt getPrice() {
    return BigInt.parse(price);
  }

  BigInt getBlockNo() {
    return BigInt.from(blockNo);
  }

  BigInt getFee() {
    return BigInt.from(fee);
  }

  BigInt getMultiplier() {
    return BigInt.from(multiplier);
  }
}
