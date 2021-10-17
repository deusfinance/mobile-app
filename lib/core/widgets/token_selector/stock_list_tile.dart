import 'dart:ui';

import '../../util/clipboard.dart';
import '../../../data_source/sync_data/sync_data.dart';
import '../../../models/synthetics/stock.dart';
import '../../../models/synthetics/stock_address.dart';
import '../../../models/token.dart';
import '../../../routes/navigation_service.dart';
import '../../../service/ethereum_service.dart';
import '../../../statics/my_colors.dart';
import '../../../statics/styles.dart';
import 'package:flutter/material.dart';

import '../../../locator.dart';

class StockListTile extends StatelessWidget {
  final Stock stock;
  final SyncData syncData;

  StockListTile({required this.stock, required this.syncData});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        locator<NavigationService>().goBack(context, stock);
      },
      contentPadding: const EdgeInsets.all(0),
      leading: stock.logoPath.showCircleImage(),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(stock.symbol,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MyStyles
                  .whiteMediumTextStyle), //const TextStyle(fontSize: 25, height: 0.99999)
          const SizedBox(
            width: 15,
          ),
          Text(stock.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MyStyles
                  .lightWhiteSmallTextStyle), //  const TextStyle(fontSize: 15, height: 0.99999)
        ],
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(EthereumService.formatDouble(stock.shortBalance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MyStyles.lightWhiteMediumTextStyle),
              const SizedBox(
                width: 8,
              ),
              Text("S",
                  overflow: TextOverflow.ellipsis,
                  style: MyStyles.lightWhiteMediumTextStyle),
              const SizedBox(
                width: 6,
              ),
              InkWell(
                  onTap: () async {
                    final StockAddress? sa = syncData.getStockAddress(stock);
                    if (sa != null) await copyToClipBoard(sa.short);
                  },
                  child: Icon(
                    Icons.copy,
                    color: MyColors.HalfWhite,
                    size: 12,
                  ))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(EthereumService.formatDouble(stock.longBalance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MyStyles.lightWhiteMediumTextStyle),
              const SizedBox(
                width: 8,
              ),
              Text("L",
                  overflow: TextOverflow.ellipsis,
                  style: MyStyles.lightWhiteMediumTextStyle),
              const SizedBox(
                width: 6,
              ),
              InkWell(
                  onTap: () async {
                    final StockAddress? sa = syncData.getStockAddress(stock);
                    if (sa != null) await copyToClipBoard(sa.long);
                  },
                  child: Icon(
                    Icons.copy,
                    color: MyColors.HalfWhite,
                    size: 12,
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
