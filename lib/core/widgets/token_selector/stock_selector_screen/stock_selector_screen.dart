import 'package:deus_mobile/core/widgets/token_selector/stock_selector.dart';
import 'package:deus_mobile/data_source/stock_data.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';

import '../token_selector.dart';
import 'package:flutter/material.dart';

class StockSelectorScreen extends StatefulWidget {
  static const url = '/MainnetAssetSelector';

  @override
  _StockSelectorScreenState createState() =>
      _StockSelectorScreenState();
}

class _StockSelectorScreenState extends State<StockSelectorScreen> {
  TextEditingController searchController = new TextEditingController();
  List<Stock> stocks;

  @override
  void initState() {
    stocks  = StockData.conductedStocks;
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
      return StockData.conductedStocks
          .where((element) =>
      element.symbol.toLowerCase().contains(pattern) ||
          element.name.toLowerCase().contains(pattern))
          .toList();

    });
    setState(() {});
  }
}
