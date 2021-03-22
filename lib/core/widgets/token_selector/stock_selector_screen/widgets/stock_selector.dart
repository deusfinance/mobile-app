import 'package:deus_mobile/core/widgets/token_selector/stock_list_tile.dart';
import 'package:flutter/material.dart';

import '../../../../../data_source/stock_data.dart';


class StockSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: StockData.values.length,
          itemBuilder: (ctx, ind) => StockListTile(
                stock : StockData.values[ind],
              )
    );
  }
}
