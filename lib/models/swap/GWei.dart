
import 'package:json_annotation/json_annotation.dart';

part 'GWei.g.dart';

@JsonSerializable(nullable: true)
class GWei{
  // @JsonKey(name:"safeLow")
  // double slow;
  // @JsonKey(name:"average")
  // double average;
  // double fast;

  double slow;
  @JsonKey(name:"standard")
  double average;
  double fast;


  GWei();

  GWei.init(this.slow, this.average, this.fast);

  double getSlow(){
    return slow/1000000000;
  }

  double getAverage(){
    return average/1000000000;
  }

  double getFast(){
    return fast/1000000000;
  }

  factory GWei.fromJson(Map<String, dynamic> json) => _$GWeiFromJson(json);
  Map<String, dynamic> toJson() => _$GWeiToJson(this);
}