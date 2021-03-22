
import 'package:json_annotation/json_annotation.dart';

part 'stock_price_detail.g.dart';

@JsonSerializable(nullable: true)
class StockPriceDetail{
  double price;
  double fee;
  @JsonKey(name: 'is_close')
  bool isClosed;

  StockPriceDetail(this.price, this.fee, this.isClosed);

  factory StockPriceDetail.fromJson(Map<String, dynamic> json) => _$StockPriceDetailFromJson(json);
  Map<String, dynamic> toJson() => _$StockPriceDetailToJson(this);
}