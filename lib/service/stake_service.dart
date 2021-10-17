import '../models/swap/gas.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class StakeService {
  final EthereumService ethService;
  final String privateKey;

  StakeService({required this.ethService, required this.privateKey});

  Future<Credentials> get credentials =>
      ethService.credentialsForKey(privateKey);

  Future<EthereumAddress> get address async =>
      (await credentials).extractAddress();

  Future<String> getTokenBalance(String tokenName) async {
    if (tokenName == "eth") {
      return this.getEtherBalance();
    }
    final tokenContract = await ethService.loadTokenContract(tokenName);
    final result =
        await ethService.query(tokenContract, "balanceOf", [await address]);

    return EthereumService.fromWei(result.single);
  }

  Future<String> getEtherBalance() async {
    return (await ethService.getEtherBalance(await credentials))
        .getInEther
        .toString();
  }

  Future<String> getAllowances(String stakedToken) async {
    final DeployedContract tokenContract =
        await ethService.loadTokenContract(stakedToken);
    final res = await ethService.query(tokenContract, "allowance",
        [await address, await ethService.getTokenAddr(stakedToken, "staking")]);
    return EthereumService.fromWei(res.single);
  }

  Future<String> approve(String stakedToken, Gas gas) async {
    const amount = "10000000000";
    final DeployedContract tokenContract =
        await ethService.loadTokenContract(stakedToken);
    final res = await ethService.submit(
        await credentials,
        tokenContract,
        "approve",
        [
          await ethService.getTokenAddr(stakedToken, "staking"),
          EthereumService.getWei(amount)
        ],
        gas: gas);
    return res;
  }

  Future<Transaction?> makeApproveTransaction(String stakedToken) async {
    const amount = "10000000000";
    final DeployedContract tokenContract =
        await ethService.loadTokenContract(stakedToken);
    final res = await ethService
        .makeTransaction(await credentials, tokenContract, "approve", [
      await ethService.getTokenAddr(stakedToken, "staking"),
      EthereumService.getWei(amount)
    ]);
    return res;
  }

  Future<String> stake(String stakedToken, String amount, Gas gas) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "staking", await ethService.getTokenAddr(stakedToken, "staking"));
    return await ethService.submit(await credentials, contract, "deposit",
        [EthereumService.getWei(amount)],
        gas: gas);
  }

  Future<Transaction?> makeStakeTransaction(
      String stakedToken, String amount) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "staking", await ethService.getTokenAddr(stakedToken, "staking"));
    return await ethService.makeTransaction(await credentials, contract,
        "deposit", [EthereumService.getWei(amount)]);
  }

  Future<String> getUserWalletStakedTokenBalance(String stakedToken) async {
    final DeployedContract tokenContract =
        await ethService.loadTokenContract(stakedToken);
    final res =
        await ethService.query(tokenContract, "balanceOf", [await address]);
    return EthereumService.fromWei(res[0]);
  }

  Future<String> withdraw(String stakedToken, String amount) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "staking", await ethService.getTokenAddr(stakedToken, "staking"));
    return await ethService.submit(await credentials, contract, "withdraw",
        [EthereumService.getWei(amount)]);
  }

  Future<String> getNumberOfStakedTokens(String stakedToken) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "staking", await ethService.getTokenAddr(stakedToken, "staking"));
    final res = await ethService.query(contract, "users", [await address]);
//    TODO depositAmount
    return EthereumService.fromWei(res[0]);
  }

  Future<String> getNumberOfPendingRewardTokens(String stakedToken) async {
    final DeployedContract contract =
        await ethService.loadContractWithGivenAddress(
            "staking", await ethService.getTokenAddr(stakedToken, "staking"));
    final res =
        await ethService.query(contract, "pendingReward", [await address]);
    return EthereumService.fromWei(res[0]);
  }

  Future<String> getTotalStakedToken(String stakedToken) async {
    final DeployedContract contract =
        await ethService.loadTokenContract(stakedToken);
    final res = await ethService.query(contract, "balanceOf",
        [await ethService.getTokenAddr(stakedToken, "staking")]);
    return EthereumService.fromWei(res[0]);
  }
}
