import 'stock_price_detail.dart';

class StockPrice {
  StockPriceDetail long;
  StockPriceDetail short;

  StockPrice(this.long, this.short);

  @override
  String toString() {
    return long.toString() + " " + short.toString();
  }
}
