import 'package:json_annotation/json_annotation.dart';

part 'GWei.g.dart';

@JsonSerializable()
class GWei {
  double? _slow;
  @JsonKey(name: "standard")
  double? _average;
  double? _fast;

  GWei();

  GWei.init(slow, average, fast) {
    _slow = slow;
    _average = average;
    _fast = fast;
  }

  double getSlow() {
    return slow / 1000000000;
  }

  double getAverage() {
    return average / 1000000000;
  }

  double getFast() {
    return fast / 1000000000;
  }

  double get slow => _slow ?? 0.0;

  set slow(double? value) {
    _slow = value;
  }

  factory GWei.fromJson(Map<String, dynamic> json) => GWei()
    ..slow = (json['slow'] as num).toDouble()
    ..average = (json['standard'] as num).toDouble()
    ..fast = (json['fast'] as num).toDouble();

  Map<String, dynamic> toJson() => _$GWeiToJson(this);

  double get average => _average ?? 0.0;

  set average(double? value) {
    _average = value;
  }

  double get fast => _fast ?? 0.0;

  set fast(double? value) {
    _fast = value;
  }
}
