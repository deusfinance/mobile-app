import 'dart:math';

import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:deus_mobile/service/sync/sync_service.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import '../ethereum_service.dart';

class XDaiStockService extends SyncService {
  String marketMaker = "0xc2fB644cd18325C58889Cf8BB0573e4a8774BCD2";
  String wxdaiProxy = "0x89951F2546f36789072c72C94272a68970Eba65e";
  static String xdaiTokenAddress = "0x0000000000000000000000000000000000000001";

  XDaiStockService({required ethService, required privateKey}): super(ethService, privateKey);

  @override
  Future<String> getAllowances(tokenAddress) async {
    if (tokenAddress == XDaiStockService.xdaiTokenAddress) {
      return "1000000000000000";
    }
    DeployedContract tokenContract =
    await ethService.loadContractWithGivenAddress("token",EthereumAddress.fromHex(tokenAddress));
    final res = await ethService
        .query(tokenContract, "allowance", [await address, EthereumAddress.fromHex(wxdaiProxy)]);

    return EthereumService.fromWei(res.single, 'ether');
  }

  @override
  Future<String> approve(String tokenAddress, Gas gas) async {
    var amount = "10000000000000000000000000000";
    DeployedContract tokenContract =
    await ethService.loadContractWithGivenAddress("token",EthereumAddress.fromHex(tokenAddress));
    var res = ethService.submit(await credentials, tokenContract, "approve",
        [EthereumAddress.fromHex(wxdaiProxy), EthereumService.getWei(amount)], gas: gas);
    return res;
  }
  @override
  Future<Transaction> makeApproveTransaction(tokenAddress) async {
    var amount = "10000000000000000000000000000";
    DeployedContract tokenContract =
    await ethService.loadContractWithGivenAddress("token",EthereumAddress.fromHex(tokenAddress));
    var res = ethService.makeTransaction(await credentials, tokenContract, "approve",
        [EthereumAddress.fromHex(wxdaiProxy), EthereumService.getWei(amount)]);
    return res;
  }

  @override
  Future<String> getTokenBalance(String tokenAddress) async {
    if (tokenAddress == XDaiStockService.xdaiTokenAddress) {
     var res = await ethService.getEtherBalance(await credentials);
     return EthereumService.fromWei(res.getInWei);
    }
    DeployedContract tokenContract = await ethService.loadContractWithGivenAddress("token", EthereumAddress.fromHex(tokenAddress));

    final res =
    await ethService.query(tokenContract, "balanceOf", [await address]);
    return EthereumService.fromWei(res.single);
  }

  @override
  Future<String> buy(tokenAddress, String amount, List<ContractInputData> oracles, Gas gas , {String? maxPrice}) async {
      DeployedContract contract =
      await ethService.loadContractWithGivenAddress(
          "wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
      ContractInputData info = oracles[0];

      var res = await ethService.query(contract, "calculateXdaiAmount", [
        BigInt.parse(maxPrice!),
        BigInt.from(info.fee),
        EthereumService.getWei(amount)
      ]);

      BigInt xdaiAmount = BigInt.parse(res.single.toString());
      return await ethService.submit(await credentials, contract, "buy", [
        info.getMultiplier(),
        EthereumAddress.fromHex(tokenAddress),
        EthereumService.getWei(amount),
        info.getFee(),
        [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
        [oracles[0].getPrice(), oracles[1].getPrice()],
        [oracles[0].signs['buy']!.getV(), oracles[1].signs['buy']!.getV()],
        [oracles[0].signs['buy']!.getR(), oracles[1].signs['buy']!.getR()],
        [oracles[0].signs['buy']!.getS(), oracles[1].signs['buy']!.getS()],
      ], value: EtherAmount.fromUnitAndValue(EtherUnit.wei, xdaiAmount)
      ,gas: gas);
  }

  @override
  Future<Transaction> makeBuyTransaction(tokenAddress, String amount, List<ContractInputData> oracles,  {String? maxPrice}) async {
      DeployedContract contract =
      await ethService.loadContractWithGivenAddress(
          "wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
      ContractInputData info = oracles[0];

      var res = await ethService.query(contract, "calculateXdaiAmount", [
        BigInt.parse(maxPrice!),
        BigInt.from(info.fee),
        EthereumService.getWei(amount)
      ]);

      BigInt xdaiAmount = BigInt.parse(res.single.toString());
      return await ethService.makeTransaction(await credentials, contract, "buy", [
        info.getMultiplier(),
        EthereumAddress.fromHex(tokenAddress),
        EthereumService.getWei(amount),
        info.getFee(),
        [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
        [oracles[0].getPrice(), oracles[1].getPrice()],
        [oracles[0].signs['buy']!.getV(), oracles[1].signs['buy']!.getV()],
        [oracles[0].signs['buy']!.getR(), oracles[1].signs['buy']!.getR()],
        [oracles[0].signs['buy']!.getS(), oracles[1].signs['buy']!.getS()],
      ], value: EtherAmount.fromUnitAndValue(EtherUnit.wei, xdaiAmount));
  }

  @override
  Future<String> sell(tokenAddress, String amount, List<ContractInputData> oracles, Gas gas) async {
    DeployedContract contract =
    await ethService.loadContractWithGivenAddress("wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
    ContractInputData info = oracles[0];

    return ethService.submit(await credentials, contract, "sell", [
      info.getMultiplier(),
      EthereumAddress.fromHex(tokenAddress),
      EthereumService.getWei(amount),
      info.getFee(),
      [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
      [oracles[0].getPrice(), oracles[1].getPrice()],
      [oracles[0].signs['sell']!.getV(), oracles[1].signs['sell']!.getV()],
      [oracles[0].signs['sell']!.getR(), oracles[1].signs['sell']!.getR()],
      [oracles[0].signs['sell']!.getS(), oracles[1].signs['sell']!.getS()],
    ],
    gas: gas);
  }

  @override
  Future<Transaction> makeSellTransaction(tokenAddress, String amount, List<ContractInputData> oracles) async {
    DeployedContract contract =
    await ethService.loadContractWithGivenAddress("wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
    ContractInputData info = oracles[0];

    return ethService.makeTransaction(await credentials, contract, "sell", [
      info.getMultiplier(),
      EthereumAddress.fromHex(tokenAddress),
      EthereumService.getWei(amount),
      info.getFee(),
      [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
      [oracles[0].getPrice(), oracles[1].getPrice()],
      [oracles[0].signs['sell']!.getV(), oracles[1].signs['sell']!.getV()],
      [oracles[0].signs['sell']!.getR(), oracles[1].signs['sell']!.getR()],
      [oracles[0].signs['sell']!.getS(), oracles[1].signs['sell']!.getS()],
    ]);
  }

  @override
  Future<String> getUsedCap() async {
    DeployedContract contract =
        await ethService.loadContractWithGivenAddress("synchronizer", EthereumAddress.fromHex(this.marketMaker));
    final res = await ethService.query(contract, "remainingDollarCap", []);
    return EthereumService.fromWei(res.single, "ether");
  }
}
