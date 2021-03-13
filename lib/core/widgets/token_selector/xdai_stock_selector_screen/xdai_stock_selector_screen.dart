
import 'package:deus_mobile/core/widgets/token_selector/xdai_stock_selector_screen/widgets/xdai_stock_selector.dart';
import 'package:flutter/material.dart';

import '../token_selector.dart';

class XDaiStockSelectorScreen extends StatelessWidget {
  static const url = '/XDaiAssetSelector';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TokenSelector(selector: XDaiStockSelector(), title: 'Asset', showSearchBar: true,),
    );
  }
}
