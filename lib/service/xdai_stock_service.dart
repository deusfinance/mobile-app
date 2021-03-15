import 'dart:math';

import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:deus_mobile/models/synthetics/xdai_contract_input_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class XDaiStockService {
  final EthereumService ethService;
  final String privateKey;
  String marketMaker;
  String wxdaiProxy;
  String xdaiTokenAddress = "0x0000000000000000000000000000000000000001";

  XDaiStockService({@required this.ethService, @required this.privateKey}) {
    _init();
  }

  _init() async {
    if (ethService.chainId == 100) {
      this.marketMaker = "0xc2fB644cd18325C58889Cf8BB0573e4a8774BCD2";
      this.wxdaiProxy = "0x89951F2546f36789072c72C94272a68970Eba65e";
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
  Future<String> getAllowances(tokenAddress) async {
    if (!checkWallet()) {
      return "0";
    }
    if (tokenAddress == this.xdaiTokenAddress) {
      return "1000000000000000";
    }
    DeployedContract tokenContract =
    await ethService.loadContractWithGivenAddress("token",EthereumAddress.fromHex(tokenAddress));
    final res = await ethService
        .query(tokenContract, "allowance", [await address, EthereumAddress.fromHex(wxdaiProxy)]);

    return EthereumService.fromWei(res.single, 'ether');
  }

  Future<String> approve(tokenAddress) async {
    if (!checkWallet()) {
      return "0";
    }
    var amount = "10000000000000000000000000000";
    DeployedContract tokenContract =
    await ethService.loadContractWithGivenAddress("token",EthereumAddress.fromHex(tokenAddress));
    var res = ethService.submit(await credentials, tokenContract, "approve",
        [EthereumAddress.fromHex(wxdaiProxy), EthereumService.getWei(amount)]);
    return res;
  }

  Future<String> getTokenBalance(String tokenAddress) async {
    if (!checkWallet())
      return "0";

    if (tokenAddress == this.xdaiTokenAddress) {
     var res = await ethService.getEtherBalance(await credentials);
     return EthereumService.fromWei(res.getInWei);
    }
    DeployedContract tokenContract = await ethService.loadContractWithGivenAddress("token", EthereumAddress.fromHex(tokenAddress));

    final res =
    await ethService.query(tokenContract, "balanceOf", [await address]);
    return EthereumService.fromWei(res.single);
  }

  Future<String> buy(tokenAddress, String amount, List<XDaiContractInputData> oracles, maxPrice) async {
    if (!checkWallet()) return "0";

    DeployedContract contract =
    await ethService.loadContractWithGivenAddress("wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
    XDaiContractInputData info = oracles[0];

    String xdaiAmount = await ethService.submit(await credentials, contract, "calculateXdaiAmount", [
      maxPrice,
      info.fee.toString(),
      EthereumService.getWei(amount)
    ]);

    return ethService.submit(await credentials, contract, "buy", [
      info.multiplier,
      address.toString(),
      EthereumService.getWei(amount),
      info.fee.toString(),
      [oracles[0].blockNo.toString(), oracles[1].blockNo.toString()],
      [oracles[0].price, oracles[1].price],
      [oracles[0].signs[0].v.toString(), oracles[1].signs[0].v.toString()],
      [oracles[0].signs[0].r.toString(), oracles[1].signs[0].r.toString()],
      [oracles[0].signs[0].s.toString(), oracles[1].signs[0].s.toString()],
    ],value: EtherAmount.fromUnitAndValue(EtherUnit.wei, xdaiAmount));
  }

  Future<String> sell(tokenAddress, String amount, List<XDaiContractInputData> oracles) async {
    if (!checkWallet()) return "0";
    //TODO
    DeployedContract contract =
    await ethService.loadContractWithGivenAddress("wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
    XDaiContractInputData info = oracles[0];

    return ethService.submit(await credentials, contract, "sell", [
      info.multiplier,
      address.toString(),
      EthereumService.getWei(amount),
      info.fee.toString(),
      [oracles[0].blockNo.toString(), oracles[1].blockNo.toString()],
      [oracles[0].price, oracles[1].price],
      [oracles[0].signs[1].v.toString(), oracles[1].signs[1].v.toString()],
      [oracles[0].signs[1].r.toString(), oracles[1].signs[1].r.toString()],
      [oracles[0].signs[1].s.toString(), oracles[1].signs[1].s.toString()],
    ]);
  }

  Future getUsedCap() async {
    DeployedContract contract =
        await ethService.loadContractWithGivenAddress("xdai_synchronizer", EthereumAddress.fromHex(this.marketMaker));
    final res = await ethService.query(contract, "remainingDollarCap", []);
    return EthereumService.fromWei(res.single, "ether");
  }
}
