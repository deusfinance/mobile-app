import '../token_selector.dart';
import 'widgets/currency_selector.dart';
import 'package:flutter/material.dart';

class CurrencySelectorScreen extends StatelessWidget {
  static const url = '/currencyScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TokenSelector(
      selector: CurrencySelector(),
      title: 'Token',
      showSearchBar: false,
    ));
  }
}
