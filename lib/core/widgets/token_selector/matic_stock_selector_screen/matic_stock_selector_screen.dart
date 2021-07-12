import 'dart:async';

import 'package:deus_mobile/core/widgets/token_selector/stock_selector.dart';
import 'package:deus_mobile/data_source/sync_data/matic_stock_data.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:flutter/material.dart';

import '../token_selector.dart';

class MaticStockSelectorScreen extends StatefulWidget {
  static const url = '/MaticAssetSelector';

  @override
  _MaticStockSelectorScreenState createState() =>
      _MaticStockSelectorScreenState();
}

class _MaticStockSelectorScreenState extends State<MaticStockSelectorScreen> {
  TextEditingController searchController = new TextEditingController();
  late List<Stock> stocks;
  late MaticStockData maticStockData;


  _MaticStockSelectorScreenState(){
    maticStockData = new MaticStockData();
  }

  @override
  void initState() {
    stocks  = maticStockData.conductedStocks;
    searchController.addListener(search);
    super.initState();
  }

  @override
  void dispose() {
    searchController.removeListener(search);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TokenSelector(selector: StockSelector(stocks, maticStockData), title: 'Asset', showSearchBar: true, searchController: searchController,),
    );
  }

  void search() async {
    String pattern = searchController.text;
    stocks = await Future.sync(() {
      return maticStockData.conductedStocks
          .where((element) =>
              element.symbol.toLowerCase().contains(pattern) ||
              element.name.toLowerCase().contains(pattern))
          .toList();

    });
    setState(() {});
  }
}
