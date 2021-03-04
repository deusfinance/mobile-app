
import 'package:json_annotation/json_annotation.dart';

part 'stock_address.g.dart';

@JsonSerializable(nullable: true)
class StockAddress {
  String id;
  String long;
  String short;


  StockAddress(this.id, this.long, this.short);


  factory StockAddress.fromJson(Map<String, dynamic> json) => _$StockAddressFromJson(json);
  Map<String, dynamic> toJson() => _$StockAddressToJson(this);

}
