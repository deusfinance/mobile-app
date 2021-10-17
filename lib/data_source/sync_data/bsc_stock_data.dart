import 'dart:convert';

import '../backend_endpoints.dart';
import 'sync_data.dart';
import '../../models/synthetics/contract_input_data.dart';
import '../../models/synthetics/stock_address.dart';
import '../../models/synthetics/stock_price.dart';
import '../../models/synthetics/stock_price_detail.dart';
import 'package:http/http.dart' as http;

class BscStockData extends SyncData {
  @override
  Future<Map<String, StockPrice>> getPrices() async {
    final response = await http.get(BackendEndpoints.PRICE_JSON_BSC_1);
    if (response.statusCode == 200) {
      final Map<String, Map<String, dynamic>> map = json.decode(response.body);
      final Map<String, StockPrice> prices = new Map();
      map.forEach((key, value) {
        final StockPrice p = new StockPrice(
            new StockPriceDetail.fromJson(value["Long"]),
            new StockPriceDetail.fromJson(value['Short']));
        prices.addEntries([new MapEntry(key.toLowerCase(), p)]);
      });
      return prices;
    } else {
      final Map<String, StockPrice> prices = new Map();
      return prices;
    }
  }

  @override
  Future<bool> getStockAddresses() async {
    if (addresses.isNotEmpty) return true;
    final response = await http
        .get(Uri.parse("https://oracle1.deus.finance/bsc/conducted.json"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> js = json.decode(response.body);
      final List<Map<String, dynamic>> map = js['tokens'];
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
    final response = await http.get(BackendEndpoints.SIGNATURES_JSON_BSC_1);
    if (response.statusCode == 200) {
      final Map<String, ContractInputData> contractInputData = new Map();
      final Map<String, dynamic> map = json.decode(response.body);
      map.forEach((key, value) {
        final ContractInputData c = ContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }

  @override
  Future<Map<String, ContractInputData>?> getInfoOracle2() async {
    final response = await http.get(BackendEndpoints.SIGNATURES_JSON_BSC_2);
    if (response.statusCode == 200) {
      final Map<String, ContractInputData> contractInputData = new Map();
      final Map<String, dynamic> map = json.decode(response.body);
      map.forEach((key, value) {
        final ContractInputData c = ContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }

  @override
  Future<Map<String, ContractInputData>?> getInfoOracle3() async {
    final response = await http.get(BackendEndpoints.SIGNATURES_JSON_BSC_3);
    if (response.statusCode == 200) {
      final Map<String, ContractInputData> contractInputData = new Map();
      final Map<String, dynamic> map = json.decode(response.body);
      map.forEach((key, value) {
        final ContractInputData c = ContractInputData.fromJson(value);
        contractInputData.addEntries([new MapEntry(key, c)]);
      });
      return contractInputData;
    } else {
      return null;
    }
  }
}
