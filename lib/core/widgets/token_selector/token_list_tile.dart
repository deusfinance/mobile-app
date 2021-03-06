import 'dart:ui';

import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

import '../../../models/token.dart';

class TokenListTile extends StatelessWidget {
  final Token token;

  TokenListTile({@required this.token});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pop(context, token);
      },
      contentPadding: const EdgeInsets.all(0),
      leading: token.logoPath.showCircleImage(),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(token.symbol,maxLines: 1,overflow: TextOverflow.ellipsis, style: MyStyles.whiteMediumTextStyle), //const TextStyle(fontSize: 25, height: 0.99999)
          const SizedBox(
            width: 15,
          ),
          Text(token.name, maxLines: 1,overflow: TextOverflow.ellipsis, style: MyStyles.lightWhiteSmallTextStyle), //  const TextStyle(fontSize: 15, height: 0.99999)
        ],
      ),
      trailing: Text(
        '0',
        style: MyStyles.whiteSmallTextStyle,
      ),
    );
  }
}
