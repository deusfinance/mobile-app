import '../../../../../data_source/currency_data.dart';

import 'package:flutter/material.dart';

import '../../token_list_tile.dart';

class CurrencySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: CurrencyData.all.length,
        itemBuilder: (ctx, ind) =>
            TokenListTile(currency: CurrencyData.all[ind]));
  }
}
