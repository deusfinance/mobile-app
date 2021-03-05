import 'dart:math';

import 'package:deus/models/contract_input_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class StockService {
  final EthereumService ethService;
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

  Future<Credentials> get credentials =>
      ethService.credentialsForKey(privateKey);

  Future<EthereumAddress> get address async =>
      (await credentials).extractAddress();

  bool checkWallet() {
    return ethService != null && this.privateKey != null;
  }
  Future<String> getAllowances(tokenName) async {
    if (!checkWallet()) {
      return "0";
    }
    if (tokenName != "dai") {
      return "1000000000000000";
    }
    DeployedContract tokenContract =
    await ethService.loadTokenContract(tokenName);
    final res = await ethService
        .query(tokenContract, "allowance", [await address, EthereumAddress.fromHex(marketMaker)]);

    return EthereumService.fromWei(res.single, tokenName);
  }

  Future<String> approve(tokenName) async {
    if (!checkWallet()) {
      return "0";
    }
    var amount = "10000000000000000000000000000";
    DeployedContract tokenContract =
    await ethService.loadTokenContract(tokenName);
    var res = ethService.submit(await credentials, tokenContract, "approve",
        [EthereumAddress.fromHex(marketMaker), EthereumService.getWei(amount, tokenName)]);
    return res;
  }

  Future<String> getTokenBalance(tokenAddress) async {
    if (!checkWallet())
      return "0";
    DeployedContract tokenContract = await ethService.loadContractWithGivenAddress("token", EthereumAddress.fromHex(tokenAddress));

    final res =
    await ethService.query(tokenContract, "balanceOf", [await address]);
    return EthereumService.fromWei(res.single);
  }

  Future<String> buy(tokenAddress, String amount, ContractInputData info) async {
    if (!checkWallet()) return "0";
    DeployedContract contract =
    await ethService.loadContractWithGivenAddress("stocks_contract", EthereumAddress.fromHex(this.marketMaker));
    return ethService.submit(await credentials, contract, "buyStock", [
      tokenAddress,
      EthereumService.getWei(amount),
      info.blockNo.toString(),
      info.price.toString(),
      info.fee.toString(),
      info.signs[0].v.toString(),
      info.signs[0].r,
      info.signs[0].s
    ]);
  }

  Future<String> sell(tokenAddress, String amount, ContractInputData info) async {
    if (!checkWallet()) return "0";
    DeployedContract contract =
    await ethService.loadContractWithGivenAddress("stocks_contract", EthereumAddress.fromHex(this.marketMaker));
    return ethService.submit(await credentials, contract, "sellStock", [
      tokenAddress,
      EthereumService.getWei(amount),
      info.blockNo.toString(),
      info.price.toString(),
      info.fee.toString(),
      info.signs[0].v.toString(),
      info.signs[0].r,
      info.signs[0].s
    ]);
  }
}
