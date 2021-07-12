
import 'dart:convert';

import 'package:deus_mobile/data_source/backend_endpoints.dart';
import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/models/synthetics/stock_address.dart';
import 'package:deus_mobile/models/synthetics/stock_price.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:http/http.dart' as http;

abstract class SyncData {
  List<Stock> values = [];
  List<Stock> conductedStocks = [];
  List<StockAddress> addresses = [];

  StockAddress? getStockAddress(Token stock) {
    for (var i = 0; i < addresses.length; i++) {
      if (addresses[i].id.toLowerCase() == stock.getTokenName()) {
        return addresses[i];
      }
    }
    return null;
  }

  StockAddress? getStockAddressFromAddress(String address) {
    for (var i = 0; i < addresses.length; i++) {
      if (addresses[i].short == address) {
        return addresses[i];
      }
      if(addresses[i].long == address) {
        return addresses[i];
      }
    }
    return null;
  }

  Stock? getStockFromAddress(StockAddress stockAddress){
    for (var i = 0; i < values.length; i++) {
      if (stockAddress.id.toLowerCase() == values[i].getTokenName()) {
        return values[i];
      }
    }
    return null;
  }


  Future<bool> getData() async {
    bool res1 = await getStockAddresses();
    bool res2 = await getValues();
    if(res1 && res2){
      getConductedData();
      return true;
    }
    return false;
  }

  Future<Map<String, StockPrice>> getPrices();

  Future<bool> getValues() async {
    if (values.isNotEmpty) return true;
    final response = await http.get(BackendEndpoints.REGISTRAR_JSON_1);
    if (response.statusCode == 200) {
      final Map<String, dynamic> map = json.decode(response.body);
      values.clear();
      map.forEach((key, value) {
        values.add(Stock.fromJson(value));
      });
      return true;
    } else {
      return false;
    }
  }

  void getConductedData() {
    if (conductedStocks.isNotEmpty) return;
    for (var i = 0; i < addresses.length; i++) {
      Stock? stock = getStockFromAddress(addresses[i]);
      if(stock!=null)
        conductedStocks.add(stock);
    }
  }

  Future<bool> getStockAddresses();

  Future<List<ContractInputData>> getContractInputData(String address, int blockNum) async {
    Map<String, ContractInputData>? oracle1 = await getInfoOracle1();
    Map<String, ContractInputData>? oracle2 = await getInfoOracle2();
    Map<String, ContractInputData>? oracle3 = await getInfoOracle3();

    List<ContractInputData> list = [];
    if (oracle1 != null && oracle1.containsKey(address) && oracle1[address]!.blockNo > blockNum) {
      list.add(oracle1[address]!);
    }
    if (oracle2 != null && oracle2.containsKey(address) && oracle2[address]!.blockNo > blockNum) {
      list.add(oracle2[address]!);
    }
    if (oracle3 != null && oracle3.containsKey(address) && oracle3[address]!.blockNo > blockNum) {
      list.add(oracle3[address]!);
    }
    return list;
  }

  Future<Map<String, ContractInputData>?> getInfoOracle1();

  Future<Map<String, ContractInputData>?> getInfoOracle2();

  Future<Map<String, ContractInputData>?> getInfoOracle3();

}
