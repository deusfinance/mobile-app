import 'dart:convert';

import '../models/stock.dart';
import 'package:http/http.dart' as http;

//TODO (@CodingDavid8) fetch all supported stocks from server
abstract class StockData {
  static const _basePath = 'images/stocks';

  static List<Stock> values = [];

//  static final Stock tesla = Stock('Tesla Inc', 'TSLA', '$_basePath/tesla.png');
//  static final Stock tesla1 = Stock('Teslaaaa Inc', 'TSLAaa', '$_basePath/tesla.png');


  static Future<bool> getdata() async {
    var response = await http.get("https://sync.deus.finance/oracle-files/registrar.json");
    if (response.statusCode == 200) {
      var map = json.decode(response.body);
      map.forEach((key, value) {
        values.add(Stock.fromJson(value));
      });

//      List<Stock> stocks = List<Stock>.from(l.map((model)=> Stock.fromJson(model)));
      print(values[0].name );
//      values = stocks;
      return true;
    } else {

    }
  }
}
