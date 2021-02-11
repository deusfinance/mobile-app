import '../models/stock.dart';

//TODO (@CodingDavid8) fetch all supported stocks from server
abstract class StockData {
  static const _basePath = 'images/stocks';

  static final List<Stock> values = [
    tesla,
    tesla,
    tesla,
    tesla,
    tesla,
    tesla,
    tesla,
    tesla,
  ];

  static final Stock tesla = Stock('Tesla Inc', 'TSLA', '$_basePath/tesla.png');
}
