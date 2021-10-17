import 'stock_list_tile.dart';
import '../../../data_source/sync_data/sync_data.dart';
import '../../../models/synthetics/stock.dart';
import 'package:flutter/material.dart';

class StockSelector extends StatelessWidget {
  final List<Stock> stocks;
  final SyncData syncData;
  StockSelector(this.stocks, this.syncData);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (ctx, ind) => StockListTile(
              stock: stocks[ind],
              syncData: syncData,
            ));
  }
}
