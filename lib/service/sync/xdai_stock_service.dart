import '../../models/swap/gas.dart';
import '../../models/synthetics/contract_input_data.dart';
import 'sync_service.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import '../ethereum_service.dart';

class XDaiStockService extends SyncService {
  String marketMaker = "0xc2fB644cd18325C58889Cf8BB0573e4a8774BCD2";
  String wxdaiProxy = "0x89951F2546f36789072c72C94272a68970Eba65e";
  static String xdaiTokenAddress = "0x0000000000000000000000000000000000000001";

  XDaiStockService({required ethService, required privateKey})
      : super(ethService, privateKey);

  @override
  Future<String> getAllowances(String tokenAddress) async {
    if (tokenAddress == XDaiStockService.xdaiTokenAddress) {
      return "1000000000000000";
    }
    final DeployedContract tokenContract =
        await ethService.loadContractWithGivenAddress(
            "token", EthereumAddress.fromHex(tokenAddress));
    final res = await ethService.query(tokenContract, "allowance",
        [await address, EthereumAddress.fromHex(wxdaiProxy)]);

    return EthereumService.fromWei(res.single, 'ether');
  }

  @override
  Future<String> approve(String tokenAddress, Gas gas) async {
    const amount = "10000000000000000000000000000";
    final DeployedContract tokenContract =
        await ethService.loadContractWithGivenAddress(
            "token", EthereumAddress.fromHex(tokenAddress));
    final res = ethService.submit(await credentials, tokenContract, "approve",
        [EthereumAddress.fromHex(wxdaiProxy), EthereumService.getWei(amount)],
        gas: gas);
    return res;
  }

  @override
  Future<Transaction> makeApproveTransaction(String tokenAddress) async {
    const amount = "10000000000000000000000000000";
    final DeployedContract tokenContract =
        await ethService.loadContractWithGivenAddress(
            "token", EthereumAddress.fromHex(tokenAddress));
    final res = ethService.makeTransaction(
        await credentials,
        tokenContract,
        "approve",
        [EthereumAddress.fromHex(wxdaiProxy), EthereumService.getWei(amount)]);
    return res;
  }

  @override
  Future<String> getTokenBalance(String tokenAddress) async {
    if (tokenAddress == XDaiStockService.xdaiTokenAddress) {
      final res = await ethService.getEtherBalance(await credentials);
      return EthereumService.fromWei(res.getInWei);
    }
    final DeployedContract tokenContract =
        await ethService.loadContractWithGivenAddress(
            "token", EthereumAddress.fromHex(tokenAddress));

    final res =
        await ethService.query(tokenContract, "balanceOf", [await address]);
    return EthereumService.fromWei(res.single);
  }

  @override
  Future<String> buy(String tokenAddress, String amount,
      List<ContractInputData> oracles, Gas gas,
      {String? maxPrice}) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
    final ContractInputData info = oracles[0];

    final res = await ethService.query(contract, "calculateXdaiAmount", [
      BigInt.parse(maxPrice!),
      BigInt.from(info.fee),
      EthereumService.getWei(amount)
    ]);

    final BigInt xdaiAmount = BigInt.parse(res.single.toString());
    return await ethService.submit(
        await credentials,
        contract,
        "buy",
        [
          info.getMultiplier(),
          EthereumAddress.fromHex(tokenAddress),
          EthereumService.getWei(amount),
          info.getFee(),
          [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
          [oracles[0].getPrice(), oracles[1].getPrice()],
          [oracles[0].signs['buy']!.getV(), oracles[1].signs['buy']!.getV()],
          [oracles[0].signs['buy']!.getR(), oracles[1].signs['buy']!.getR()],
          [oracles[0].signs['buy']!.getS(), oracles[1].signs['buy']!.getS()],
        ],
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, xdaiAmount),
        gas: gas);
  }

  @override
  Future<Transaction> makeBuyTransaction(
      String tokenAddress, String amount, List<ContractInputData> oracles,
      {String? maxPrice}) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
    final ContractInputData info = oracles[0];

    final res = await ethService.query(contract, "calculateXdaiAmount", [
      BigInt.parse(maxPrice!),
      BigInt.from(info.fee),
      EthereumService.getWei(amount)
    ]);

    final BigInt xdaiAmount = BigInt.parse(res.single.toString());
    return await ethService.makeTransaction(
        await credentials,
        contract,
        "buy",
        [
          info.getMultiplier(),
          EthereumAddress.fromHex(tokenAddress),
          EthereumService.getWei(amount),
          info.getFee(),
          [oracles[0].getBlockNo(), oracles[1].getBlockNo()],
          [oracles[0].getPrice(), oracles[1].getPrice()],
          [oracles[0].signs['buy']!.getV(), oracles[1].signs['buy']!.getV()],
          [oracles[0].signs['buy']!.getR(), oracles[1].signs['buy']!.getR()],
          [oracles[0].signs['buy']!.getS(), oracles[1].signs['buy']!.getS()],
        ],
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, xdaiAmount));
  }

  @override
  Future<String> sell(String tokenAddress, String amount,
      List<ContractInputData> oracles, Gas gas) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
    final ContractInputData info = oracles[0];

    return ethService.submit(
        await credentials,
        contract,
        "sell",
        [
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
  Future<Transaction> makeSellTransaction(String tokenAddress, String amount,
      List<ContractInputData> oracles) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "wxdai_proxy", EthereumAddress.fromHex(this.wxdaiProxy));
    final ContractInputData info = oracles[0];

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
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "synchronizer", EthereumAddress.fromHex(this.marketMaker));
    final res = await ethService.query(contract, "remainingDollarCap", []);
    return EthereumService.fromWei(res.single, "ether");
  }
}
