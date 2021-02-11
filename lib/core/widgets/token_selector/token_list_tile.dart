import 'dart:ui';

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
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(token.shortName, style: const TextStyle(fontSize: 25, height: 0.99999)),
          const SizedBox(
            width: 15,
          ),
          Text(token.name, style: const TextStyle(fontSize: 15, height: 0.99999)),
        ],
      ),
      trailing: const Text(
        '0',
        style: TextStyle(fontSize: 19),
      ),
    );
  }
}
