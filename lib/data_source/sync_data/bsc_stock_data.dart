import 'dart:convert';

import 'package:deus_mobile/data_source/backend_endpoints.dart';
import 'package:deus_mobile/data_source/sync_data/sync_data.dart';
import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:deus_mobile/models/synthetics/stock_address.dart';
import 'package:deus_mobile/models/synthetics/stock_price.dart';
import 'package:deus_mobile/models/synthetics/stock_price_detail.dart';
import 'package:http/http.dart' as http;

class BscStockData extends SyncData {
  @override
  Future<Map<String, StockPrice>> getPrices() async {
    var response = await http.get(BackendEndpoints.PRICE_JSON_BSC_1);
    if (response.statusCode == 200) {
      final Map<String, dynamic> map = json.decode(response.body);
      Map<String, StockPrice> prices = new Map();
      map.forEach((key, value) {
        StockPrice p =
        new StockPrice(new StockPriceDetail.fromJson(value["Long"]), new StockPriceDetail.fromJson(value['Short']));
        prices.addEntries([new MapEntry(key.toLowerCase(), p)]);
      });
      return prices;
    } else {
      Map<String, StockPrice> prices = new Map();
      return prices;
    }
  }
  @override
  Future<bool> getStockAddresses() async {
    if (addresses.isNotEmpty) return true;
    var response = await http.get(Uri.parse("https://oracle1.deus.finance/bsc/conducted.json"));
    if (response.statusCode == 200) {
      var js = json.decode(response.body);
      var map = js['tokens'];
      addresses.clear();
      map.forEach((value) {
        addresses.add(StockAddress.fromJson(value));
      });
      return true;
    } else {
      return false;
    }
  }
  @override
  Future<Map<String, ContractInputData>?> getInfoOracle1() async {
    var response = await http.get(BackendEndpoints.SIGNATURES_JSON_BSC_1);
    if (response.statusCode == 200) {
      Map<String, ContractInputData> contractInputData = new Map();
      var map = json.decode(response.body);
      map.forEach((key, value) {
        ContractInputData c = ContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }
  @override
  Future<Map<String, ContractInputData>?> getInfoOracle2() async {
    var response = await http.get(BackendEndpoints.SIGNATURES_JSON_BSC_2);
    if (response.statusCode == 200) {
      Map<String, ContractInputData> contractInputData = new Map();
      var map = json.decode(response.body);
      map.forEach((key, value) {
        ContractInputData c = ContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }
  @override
  Future<Map<String, ContractInputData>?> getInfoOracle3() async {
    var response = await http.get(BackendEndpoints.SIGNATURES_JSON_BSC_3);
    if (response.statusCode == 200) {
      Map<String, ContractInputData> contractInputData = new Map();
      var map = json.decode(response.body);
      map.forEach((key, value) {
        ContractInputData c = ContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }

}
