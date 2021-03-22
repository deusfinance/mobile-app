import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../token.dart';

class CryptoCurrency extends Token {
  String balance = "0";
  String allowances = "0";

  BigInt getBalance() {
    return EthereumService.getWei(balance, symbol.toLowerCase());
  }

  BigInt getAllowances() {
    return EthereumService.getWei(allowances, symbol.toLowerCase());
  }

  CryptoCurrency({
    @required String name,
    @required String symbol,
    String logoPath,
  }) : super(name, symbol, logoPath);
}
