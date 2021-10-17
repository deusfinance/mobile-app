import 'dart:async';

import '../stock_selector.dart';
import '../../../../data_source/sync_data/bsc_stock_data.dart';
import '../../../../models/synthetics/stock.dart';
import 'package:flutter/material.dart';

import '../token_selector.dart';

class BscStockSelectorScreen extends StatefulWidget {
  static const url = '/BscAssetSelector';
  final BscStockData bscStockData;

  BscStockSelectorScreen(this.bscStockData);

  @override
  _BscStockSelectorScreenState createState() => _BscStockSelectorScreenState();
}

class _BscStockSelectorScreenState extends State<BscStockSelectorScreen> {
  TextEditingController searchController = new TextEditingController();
  late List<Stock> stocks;

  @override
  void initState() {
    stocks = widget.bscStockData.conductedStocks;
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
        selector: StockSelector(stocks, widget.bscStockData),
        title: 'Asset',
        showSearchBar: true,
        searchController: searchController,
      ),
    );
  }

  void search() async {
    final String pattern = searchController.text;
    stocks = await Future.sync(() {
      return widget.bscStockData.conductedStocks
          .where((element) =>
              element.symbol.toLowerCase().contains(pattern) ||
              element.name.toLowerCase().contains(pattern))
          .toList();
    });
    setState(() {});
  }
}
