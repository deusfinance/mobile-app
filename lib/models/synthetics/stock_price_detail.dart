import 'package:json_annotation/json_annotation.dart';

class StockPriceDetail {
  double? _price;
  double? _fee;
  bool? _isClosed;

  StockPriceDetail();

  factory StockPriceDetail.fromJson(Map<String, dynamic> json){
    return StockPriceDetail()
      ..isClosed = json['isClosed'] as bool
      ..fee = json['fee']!=null?(json['fee'] as num).toDouble():null
      ..price = json['price']!=null?(json['price'] as num).toDouble():null;
  }


  @override
  String toString() {
    return 'StockPriceDetail{_price: $_price, _fee: $_fee, _isClosed: $_isClosed}';
  }

  bool get isClosed => _isClosed??false;

  set isClosed(bool value) {
    _isClosed = value;
  }

  double get fee => _fee??0.0;

  set fee(double? value) {
    _fee = value;
  }

  double get price => _price??0.0;

  set price(double? value) {
    _price = value;
  }
}
