import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class StockService {
  static const TOKEN_MAX_DIGITS = {
    "wbtc": 8,
    "usdt": 6,
    "usdc": 6,
    "coinbase": 18,
    "dea": 18,
    "deus": 18,
    "dai": 18,
    "eth": 18,
  };

  final EthereumService ethService;

  // will probably be a web3 PrivateKey
  // this.account = account;
  final String privateKey;
  String marketMaker;

  StockService({@required this.ethService, @required this.privateKey}) {
    _init();
  }

  _init() async {
    if (ethService.chainId == 1) {
      this.marketMaker = "0x15e343d8Cebb2d9b17Feb7271bB26e127aa2E537";
    } else {
      this.marketMaker = "0xBa13DaE5D0dB9B6683b4ad6b6dbee5251D18eAcb";
    }
  }

  bool checkWallet() {
    return ethService != null && this.privateKey != null;
  }

  BigInt getWei(BigInt amount, [String token = "eth"]) {
    var max =
        TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
    // let value = typeof number === "string" ? parseFloat(number).toFixed(18) : number.toFixed(18)
    var ans = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount)
        .getInWei
        .toString();
    ans = ans.substring(0, ans.length - (18 - max));
    return BigInt.parse(ans.toString());
  }

  String fromWei(BigInt value, String token) {
    var max =
        TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
    String ans = value.toString();

    while (ans.length < max) {
      ans = "0" + ans;
    }
    ans = ans.substring(0, ans.length - max) +
        "." +
        ans.substring(ans.length - max);
    if (ans[0] == ".") {
      ans = "0" + ans;
    }
    return ans;
  }

  //  TODO implement its body and arguments
  Future<BigInt> getAllowances(tokenName, tokenAddress) async {
//    if(!checkWallet()){
//      return null;
//    }
//    if (tokenAddress != ethService.getTokenAddr("dai")) {
//      return BigInt.from(1000000000000000);
//    }
//    DeployedContract tokenContract = await ethService.loadTokenContract(tokenName);
//    ethService.query(tokenContract, "allowance", [privateKey, marketMaker]).then((value) {
//      print(value);
//      return value;
//    });

    await Future.delayed(const Duration(milliseconds: 2000), () {
      return true;
    });

  }

  //  TODO implement its body and arguments
  Future<dynamic> approve(tokenAddress, tokenName) async {
//    if(!checkWallet()){
//      return 0;
//    }
//    var amount = BigInt.from(pow(10, 25));
//    if (tokenAddress != ethService.getTokenAddr("dai")) {
//      return BigInt.from(1000000000000000);
//    }
//    DeployedContract tokenContract = await ethService.loadTokenContract(tokenName);
//
//    ethService.query(tokenContract, "approve", [marketMaker, getWei(amount)]).then((value) {
//      print(value);
//      return value;
//    });
    await Future.delayed(const Duration(milliseconds: 2000), () {
      return true;
    });


  }

//  TODO implement its body and arguments
  Future<bool> buy(tokenAddress, tokenName, amount) async {
    await Future.delayed(const Duration(milliseconds: 2000), () {
      return true;
    });

  }

  //  TODO implement its body and arguments
  Future<dynamic> sell(tokenAddress, tokenName, amount) async {
    await Future.delayed(const Duration(milliseconds: 2000), () {
      return true;
    });

  }
  
  

}
