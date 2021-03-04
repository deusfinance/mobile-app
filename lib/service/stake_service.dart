import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class StakeService {
  final EthereumService ethService;
  final String privateKey;

  StakeService({@required this.ethService, @required this.privateKey});

  Future<Credentials> get credentials =>
      ethService.credentialsForKey(privateKey);

  Future<EthereumAddress> get address async =>
      (await credentials).extractAddress();


  bool checkWallet() {
    return ethService != null && this.privateKey != null;
  }

  BigInt getWei(BigInt amount) {
    var max = 18;
    var ans = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount)
        .getInWei
        .toString();
    ans = ans.substring(0, ans.length - (18 - max));
    return BigInt.parse(ans.toString());
  }

  String fromWei(BigInt value) {
    var max = 18;
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

    return this.fromWei(result.single);
  }

  Future<String> getEtherBalance() async{
    if (!this.checkWallet()) return "0";

    return (await ethService.getEtherBalance(await credentials))
    .getInEther
    .toString();
  }

  Future<String> getAllowances(stakedToken) async {
    if(!checkWallet()){
      return "0";
    }
    DeployedContract tokenContract = await ethService.loadTokenContract(stakedToken);
    final res = await ethService.query(tokenContract, "allowance", [await address, ethService.getTokenAddrHex(stakedToken,"staking")]);
    return fromWei(res.single);
  }

  Future<String> approve(stakedToken) async {
    if(!checkWallet()){
      return "0";
    }
    var amount;
    if (stakedToken != 'uni') {
      amount = BigInt.from(pow(10, 25));
    } else {
      amount = BigInt.from(pow(10, 15));
    }

    DeployedContract tokenContract = await ethService.loadTokenContract(stakedToken);
    var res = await ethService.submit(await credentials, tokenContract, "approve", [await ethService.getTokenAddrHex(stakedToken,"staking"), getWei(amount)]);
    return res;
  }

  Future<String> stake(stakedToken, amount) async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress("staking", await ethService.getTokenAddrHex(stakedToken,"staking"));
    return await ethService.submit(await credentials, contract, "deposit", [getWei(amount)]);
  }

  Future<String> getUserWalletStakedTokenBalance(stakedToken) async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract tokenContract = await ethService.loadTokenContract(stakedToken);
    var res = await ethService.query(tokenContract, "balanceOf", [await address]);
    return fromWei(res[0]);
  }

  Future<String> withdraw(stakedToken, amount)async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress("staking", await ethService.getTokenAddrHex(stakedToken,"staking"));
    return await ethService.submit(await credentials, contract, "withdraw", [getWei(amount)]);
  }

  Future<String> getNumberOfStakedTokens(stakedToken)async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress("staking", await ethService.getTokenAddrHex(stakedToken,"staking"));
    var res = await ethService.query(contract, "users", [await address]);
//    TODO depositAmount
    return fromWei(res[0]);
  }

  Future<String> getNumberOfPendingRewardTokens(stakedToken)async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress("staking", await ethService.getTokenAddrHex(stakedToken,"staking"));
    var res = await ethService.query(contract, "pendingReward", [await address]);
    return fromWei(res[0]);
  }

  Future<String> getTotalStakedToken(stakedToken)async{

    DeployedContract contract = await ethService.loadTokenContract(stakedToken);
    var res = await ethService.query(contract, "balanceOf", [await ethService.getTokenAddrHex(stakedToken, "staking")]);
    return fromWei(res[0]);
  }

}
