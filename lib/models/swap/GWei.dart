
import 'package:json_annotation/json_annotation.dart';

part 'GWei.g.dart';

@JsonSerializable(nullable: true)
class GWei{
  @JsonKey(name:"safeLow")
  double slow;
  @JsonKey(name:"average")
  double average;
  double fast;


  GWei();

  double getSlow(){
    return slow/10;
  }

  double getAverage(){
    return average/10;
  }

  double getFast(){
    return fast/10;
  }

  factory GWei.fromJson(Map<String, dynamic> json) => _$GWeiFromJson(json);
  Map<String, dynamic> toJson() => _$GWeiToJson(this);
}