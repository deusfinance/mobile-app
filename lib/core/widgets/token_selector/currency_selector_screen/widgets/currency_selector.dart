import 'package:deus/models/crypto_currency.dart';
import 'package:flutter/material.dart';

import '../../token_list_tile.dart';

class CurrencySelector extends StatelessWidget {
  final testItem =
      const CryptoCurrency(name: 'Tesla Inc', shortName: 'TSLA', logoPath: 'assets/images/currencies/eth.png');

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:
          ListView.builder(shrinkWrap: true, itemCount: 10, itemBuilder: (ctx, ind) => TokenListTile(token: testItem)),
    );
  }
}
