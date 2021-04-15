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

  Future<String> getTokenBalance(tokenName) async {
    if (!this.checkWallet()) return "0";

    if (tokenName == "eth") {
      return this.getEtherBalance();
    }
    final tokenContract = await ethService.loadTokenContract(tokenName);
    final result = await ethService.query(tokenContract, "balanceOf", [await address]);

    return EthereumService.fromWei(result.single);
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
    final res = await ethService.query(tokenContract, "allowance", [await address, await ethService.getTokenAddr(stakedToken,"staking")]);
    return EthereumService.fromWei(res.single);
  }

  Future<String> approve(stakedToken) async {
    if(!checkWallet()){
      return "0";
    }
    var amount = "10000000000000000000000000000";
    DeployedContract tokenContract = await ethService.loadTokenContract(stakedToken);
    var res = await ethService.submit(await credentials, tokenContract, "approve", [await ethService.getTokenAddr(stakedToken,"staking"), EthereumService.getWei(amount)]);
    return res;
  }

  Future<String> stake(stakedToken, amount) async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress("staking", await ethService.getTokenAddrHex(stakedToken,"staking"));
    return await ethService.submit(await credentials, contract, "deposit", [EthereumService.getWei(amount)]);
  }

  Future<String> getUserWalletStakedTokenBalance(stakedToken) async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract tokenContract = await ethService.loadTokenContract(stakedToken);
    var res = await ethService.query(tokenContract, "balanceOf", [await address]);
    return EthereumService.fromWei(res[0]);
  }

  Future<String> withdraw(stakedToken, amount)async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress("staking", await ethService.getTokenAddr(stakedToken,"staking"));
    return await ethService.submit(await credentials, contract, "withdraw", [EthereumService.getWei(amount)]);
  }

  Future<String> getNumberOfStakedTokens(stakedToken)async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress("staking", await ethService.getTokenAddr(stakedToken,"staking"));
    var res = await ethService.query(contract, "users", [await address]);
//    TODO depositAmount
    return EthereumService.fromWei(res[0]);
  }

  Future<String> getNumberOfPendingRewardTokens(stakedToken)async{
    if(!checkWallet()){
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress("staking", await ethService.getTokenAddr(stakedToken,"staking"));
    var res = await ethService.query(contract, "pendingReward", [await address]);
    return EthereumService.fromWei(res[0]);
  }

  Future<String> getTotalStakedToken(stakedToken)async{

    DeployedContract contract = await ethService.loadTokenContract(stakedToken);
    var res = await ethService.query(contract, "balanceOf", [await ethService.getTokenAddr(stakedToken, "staking")]);
    return EthereumService.fromWei(res[0]);
  }

}
