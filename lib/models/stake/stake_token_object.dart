import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:flutter/cupertino.dart';

class StakeTokenObject{
  double apy;
  String stakedAmount;
  String pendingReward;
  String max;
  CryptoCurrency lockToken;
  CryptoCurrency stakeToken;
  TextEditingController controller;


  StakeTokenObject(this.lockToken, this.stakeToken){
    this.controller = new TextEditingController();
  }

  bool isValueStaked(){
    double res = double.tryParse(stakedAmount);
    if(res != null && res>0)
      return true;
    return false;
  }

  double percOfPool(){
    return 0.12;
  }

}