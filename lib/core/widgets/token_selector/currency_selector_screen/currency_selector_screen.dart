import '../token_selector.dart';
import 'widgets/currency_selector.dart';
import 'package:flutter/material.dart';

class StockSelectorScreen extends StatelessWidget {
  static const url = '/currencyScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TokenSelector(
      selector: CurrencySelector(),
      title: 'Token',
      showSearchBar: true,
    ));
  }
}
