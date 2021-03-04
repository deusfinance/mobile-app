import 'dart:convert';

import 'package:deus_mobile/models/contract_input_data.dart';
import 'package:deus_mobile/models/stock_address.dart';

import '../models/stock.dart';
import 'package:http/http.dart' as http;

//TODO (@CodingDavid8) fetch all supported stocks from server
abstract class StockData {
  static const _basePath = 'images/stocks';

  static List<Stock> values = [];
  static List<StockAddress> addresses = [];
  static Map<String, ContractInputData> contractInputData = new Map();


  static Future<bool> getdata() async {
    var response = await http.get("https://sync.deus.finance/oracle-files/registrar.json");
    if (response.statusCode == 200) {
      var map = json.decode(response.body);
      map.forEach((key, value) {
        values.add(Stock.fromJson(value));
      });
      return true;
    } else {
      return false;
    }

  }

  static Future<bool> getStockAddress() async {
    var response = await http.get(
        "https://sync.deus.finance/oracle-files/conducted.json");
    if (response.statusCode == 200) {
      var js = json.decode(response.body);
      var map = js['tokens'];
      map.forEach((value) {
        addresses.add(StockAddress.fromJson(value));
      });
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> getInfo() async {
    var response = await http.get("https://sync.deus.finance/oracle-files/buyOrSell.json");
    if (response.statusCode == 200) {
      contractInputData.clear();
      var map = json.decode(response.body);
      map.forEach((key, value) {
        ContractInputData c = ContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return true;
    } else {
      return false;
    }

  }
}
