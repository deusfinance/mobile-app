import 'dart:async';

import 'package:deus_mobile/core/widgets/token_selector/stock_selector.dart';
import 'package:deus_mobile/data_source/xdai_stock_data.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:flutter/material.dart';

import '../token_selector.dart';

class XDaiStockSelectorScreen extends StatefulWidget {
  static const url = '/XDaiAssetSelector';

  @override
  _XDaiStockSelectorScreenState createState() =>
      _XDaiStockSelectorScreenState();
}

class _XDaiStockSelectorScreenState extends State<XDaiStockSelectorScreen> {
  TextEditingController searchController = new TextEditingController();
  List<Stock> stocks;

  @override
  void initState() {
    stocks  = XDaiStockData.conductedStocks;
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
      body: TokenSelector(selector: StockSelector(stocks), title: 'Asset', showSearchBar: true, searchController: searchController,),
    );
  }

  void search() async {
    String pattern = searchController.text;
    stocks = await Future.sync(() {
      return XDaiStockData.conductedStocks
          .where((element) =>
              element.symbol.toLowerCase().contains(pattern) ||
              element.name.toLowerCase().contains(pattern))
          .toList();

    });
    setState(() {});
  }
}
