import 'dart:async';

import '../stock_selector.dart';
import '../../../../data_source/sync_data/heco_stock_data.dart';
import '../../../../models/synthetics/stock.dart';
import 'package:flutter/material.dart';

import '../token_selector.dart';

class HecoStockSelectorScreen extends StatefulWidget {
  static const url = '/HecoAssetSelector';
  final HecoStockData hecoStockData;

  HecoStockSelectorScreen(this.hecoStockData);

  @override
  _HecoStockSelectorScreenState createState() =>
      _HecoStockSelectorScreenState();
}

class _HecoStockSelectorScreenState extends State<HecoStockSelectorScreen> {
  TextEditingController searchController = new TextEditingController();
  late List<Stock> stocks;

  @override
  void initState() {
    stocks = widget.hecoStockData.conductedStocks;
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
      body: TokenSelector(
        selector: StockSelector(stocks, widget.hecoStockData),
        title: 'Asset',
        showSearchBar: true,
        searchController: searchController,
      ),
    );
  }

  void search() async {
    final String pattern = searchController.text;
    stocks = await Future.sync(() {
      return widget.hecoStockData.conductedStocks
          .where((element) =>
              element.symbol.toLowerCase().contains(pattern) ||
              element.name.toLowerCase().contains(pattern))
          .toList();
    });
    setState(() {});
  }
}
