import 'package:deus/data_source/currency_data.dart';

import 'package:flutter/material.dart';

import '../../token_list_tile.dart';

class CurrencySelector extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: CurrencyData.all.length,
          itemBuilder: (ctx, ind) => TokenListTile(token: CurrencyData.all[ind])),
    );
  }
}
