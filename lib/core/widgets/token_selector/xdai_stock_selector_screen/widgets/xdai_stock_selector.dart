
import 'package:deus_mobile/data_source/xdai_stock_data.dart';
import 'package:flutter/cupertino.dart';

import '../../token_list_tile.dart';

class XDaiStockSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: XDaiStockData.values.length,
        itemBuilder: (ctx, ind) => TokenListTile(
              token: XDaiStockData.values[ind],
            ));
  }
}
