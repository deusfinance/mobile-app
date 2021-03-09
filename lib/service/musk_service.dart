import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class MuskService {
  static const TOKEN_MAX_DIGITS = {
  "wbtc": 8,
  "usdt": 6,
  "usdc": 6,
  "coinbase": 18,
  "dea": 18,
  "deus": 18,
  "dai": 18,
  "eth": 18,
  "bakkt": 18,
  "spcx": 18,
  };
  final EthereumService ethService;
  final String privateKey;

  MuskService({@required this.ethService, @required this.privateKey});

  Future<Credentials> get credentials =>
      ethService.credentialsForKey(privateKey);

  Future<EthereumAddress> get address async =>
      (await credentials).extractAddress();


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

  Future<String> getTokenBalance(tokenName) async {
    if (!this.checkWallet()) return "0";

    if (tokenName == "eth") {
      return this.getEtherBalance();
    }
    final tokenContract = await ethService.loadTokenContract(tokenName);
    final result = await ethService.query(tokenContract, "balanceOf", [await address]);

    return this.fromWei(result.single, tokenName);
  }

  Future<String> getEtherBalance() async{
    if (!this.checkWallet()) return "0";

    return (await ethService.getEtherBalance(await credentials))
    .getInEther
    .toString();
  }

  Future<String> getAllowances(token) async {
    if(!checkWallet()) return "0";
    if (token == "eth") return "99999";

    DeployedContract tokenContract = await ethService.loadTokenContract(token);
    final res = await ethService.query(tokenContract, "allowance", [await address, ethService.getAddrHex("spcx_swap_contract")]);
    return fromWei(res.single, token);
  }

  Future<String> approve(token) async {
    if(!checkWallet()){
      return "0";
    }
    var amount = BigInt.from(pow(10, 25));

    DeployedContract tokenContract = await ethService.loadTokenContract(token);
    var res = await ethService.submit(await credentials, tokenContract, "approve", [await ethService.getAddrHex("spcx_swap_contract"), getWei(amount, token)]);
    return res;
  }

  Future<String> swapTokens(fromToken, toToken, tokenAmount) async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract  = await ethService.loadContractWithGivenAddress("bakkt_swap_contract", await ethService.getAddrHex("spcx_swap_contract"));
    if(fromToken == "spcx" && toToken == "dea"){
      var res = await ethService.query(contract, "calculateSaleReturn", [getWei(tokenAmount, toToken)]);
      var deaAmount = fromWei(res.single, toToken);
//      TODO
//      return await ethService.submit(await credentials, contract, "sell", [getWei(tokenAmount, fromToken), getWei(BigInt.from(0.95 * deaAmount), toToken)]);

    }
    else if(fromToken == "dea" && toToken == "spcx") {
      var res = await ethService.query(contract, "calculatePurchaseReturn", [getWei(tokenAmount)]);
      var spcxAmount = fromWei(res[0], toToken);
      //      TODO
//      return await ethService.submit(await credentials, contract, "buy", [getWei(BigInt.from(0.95 * spcxAmount), toToken), getWei(tokenAmount, toToken)]);
    }
    return "0";
  }

  Future<String> getAmountsOut(fromToken, toToken, amountIn) async{
    DeployedContract spcxContract = await ethService.loadContractWithGivenAddress("sps", await ethService.getAddrHex("spcx_swap_contract"));
    if(fromToken == "spcx" && toToken == "dea"){
      var res = await ethService.query(spcxContract, "calculateSaleReturn", [getWei(amountIn, fromToken)]);
      return fromWei(res[0], toToken);
    }else if(fromToken == "dea" && toToken == "spcx"){
      var res = await ethService.query(spcxContract, "calculatePurchaseReturn", [getWei(amountIn, fromToken)]);
      return fromWei(res[0], toToken);
    }
  }

  getAmountsIn(fromToken, toToken, amountOut) {
    return -1;
  }

}
