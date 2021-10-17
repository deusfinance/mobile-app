import 'package:flutter/material.dart';

import '../swap/crypto_currency.dart';

class StakeTokenObject {
  late double apy;
  late String stakedAmount;
  late String pendingReward;
  late String max;
  CryptoCurrency lockToken;
  CryptoCurrency stakeToken;
  late TextEditingController controller;

  StakeTokenObject(this.lockToken, this.stakeToken) {
    this.controller = new TextEditingController();
  }

  bool isValueStaked() {
    final double? res = double.tryParse(stakedAmount)!;
    if (res != null && res > 0) return true;
    return false;
  }

  double percOfPool() {
    return 0.12;
  }
}
