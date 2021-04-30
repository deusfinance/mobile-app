import 'package:deus_mobile/core/widgets/token_selector/stock_list_tile.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:flutter/material.dart';

import '../../../../../data_source/stock_data.dart';


class StockSelector extends StatelessWidget {
  List<Stock> stocks;

  StockSelector(this.stocks);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (ctx, ind) => StockListTile(
          stock: stocks[ind],
        ));
  }
}
