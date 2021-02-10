import 'package:flutter/material.dart';

import '../../../../../models/stock.dart';
import '../../token_list_tile.dart';

class StockSelector extends StatelessWidget {
  final testItem = Stock('Tesla Inc', 'TSLA', 'assets/images/currencies/eth.png');

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (ctx, ind) => TokenListTile(
              token: testItem,
            ));
  }
}
