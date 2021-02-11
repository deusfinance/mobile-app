import '../token_selector.dart';
import 'widgets/stock_selector.dart';
import 'package:flutter/material.dart';

class StockSelectorScreen extends StatelessWidget {
  static const url = '/AssetSelector';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TokenSelector(selector: StockSelector(), title: 'Asset'),
    );
  }
}
