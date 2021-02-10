import 'package:flutter/material.dart';

import '../../../../../data_source/stock_data.dart';
import '../../token_list_tile.dart';

class StockSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: StockData.values.length,
        itemBuilder: (ctx, ind) => TokenListTile(
              token: StockData.values[ind],
            ));
  }
}
