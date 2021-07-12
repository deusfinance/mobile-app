import 'dart:ui';

import 'package:deus_mobile/core/util/clipboard.dart';
import 'package:deus_mobile/data_source/sync_data/sync_data.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/models/synthetics/stock_address.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

import '../../../locator.dart';

class StockListTile extends StatelessWidget {
  final Stock stock;
  SyncData syncData;

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
          Text(stock.symbol,maxLines: 1,overflow: TextOverflow.ellipsis, style: MyStyles.whiteMediumTextStyle), //const TextStyle(fontSize: 25, height: 0.99999)
          const SizedBox(
            width: 15,
          ),
          Text(stock.name, maxLines: 1,overflow: TextOverflow.ellipsis, style: MyStyles.lightWhiteSmallTextStyle), //  const TextStyle(fontSize: 15, height: 0.99999)
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
              Text(EthereumService.formatDouble(stock.shortBalance), maxLines: 1,overflow: TextOverflow.ellipsis, style: MyStyles.lightWhiteMediumTextStyle),
              SizedBox(width: 8,),
              Text("S",overflow: TextOverflow.ellipsis, style: MyStyles.lightWhiteMediumTextStyle),
              SizedBox(width: 6,),
              InkWell(
                  onTap: () async {
                    StockAddress? sa = syncData.getStockAddress(stock);
                    if(sa!= null)
                      await copyToClipBoard(sa.short);
                  },
                  child: Icon(Icons.copy, color: MyColors.HalfWhite,size: 12,))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(EthereumService.formatDouble(stock.longBalance), maxLines: 1,overflow: TextOverflow.ellipsis, style: MyStyles.lightWhiteMediumTextStyle),
              SizedBox(width: 8,),
              Text("L",overflow: TextOverflow.ellipsis, style: MyStyles.lightWhiteMediumTextStyle),
              SizedBox(width: 6,),
              InkWell(
                  onTap: () async {
                    StockAddress? sa = syncData.getStockAddress(stock);
                    if(sa!= null)
                      await copyToClipBoard(sa.long);
                  },
                  child: Icon(Icons.copy, color: MyColors.HalfWhite,size: 12,))
            ],
          ),
        ],
      ),
    );
  }
}