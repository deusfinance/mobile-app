import 'dart:ui';

import 'package:deus/models/token.dart';
import 'package:flutter/material.dart';

import '../../../models/crypto_currency.dart';

class TokenListTile extends StatelessWidget {
  final Token token;

  TokenListTile({@required this.token});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(token.logoPath)),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(token.shortName,
              style: const TextStyle(fontSize: 25, height: 0.99999)),
          const SizedBox(
            width: 15,
          ),
          Text(token.name,
              style: const TextStyle(fontSize: 15, height: 0.99999)),
        ],
      ),
      trailing: const Text(
        '0',
        style: TextStyle(fontSize: 19),
      ),
    );
  }
}
