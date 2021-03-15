import 'package:deus_mobile/data_source/xdai_stock_data.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:flutter/cupertino.dart';

import '../../stock_list_tile.dart';

class XDaiStockSelector extends StatelessWidget {
  List<Stock> stocks;

  XDaiStockSelector(this.stocks);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (ctx, ind) => StockListTile(
              stock: stocks[ind],
            ));
  }
}
