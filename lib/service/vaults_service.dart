// import 'dart:math';
//
// import '../models/swap/gas.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:web3dart/web3dart.dart';
//
// import 'ethereum_service.dart';
//
// class VaultsService {
//   static const TOKEN_MAX_DIGITS = {
//     "wbtc": 8,
//     "usdt": 6,
//     "usdc": 6,
//     "coinbase": 18,
//     "dea": 18,
//     "deus": 18,
//     "dai": 18,
//     "eth": 18,
//   };
//
//   final EthereumService ethService;
//   final String privateKey;
//
//   VaultsService({required this.ethService, required this.privateKey});
//
//   Future<Credentials> get credentials =>
//       ethService.credentialsForKey(privateKey);
//
//   Future<EthereumAddress> get address async =>
//       (await credentials).extractAddress();
//
//
//   Future<String> getTokenBalance(tokenName) async {
//     if (tokenName == "eth") {
//       return this.getEtherBalance();
//     }
//     final tokenContract = await ethService.loadTokenContract(tokenName);
//     final result =
//         await ethService.query(tokenContract, "balanceOf", [await address]);
//
//     return EthereumService.fromWei(result.single, tokenName);
//   }
//
//   Future<String> getEtherBalance() async {
//     return (await ethService.getEtherBalance(await credentials))
//         .getInEther
//         .toString();
//   }
//
//   Future<String> getTokenTotalSupply(tokenName) async {
//     final tokenContract = await ethService.loadTokenContract(tokenName);
//     final result = await ethService.query(tokenContract, "totalSupply", []);
//     return EthereumService.fromWei(result.single, tokenName);
//   }
//
//   Future<String> getAllowances(tokenName) async {
//     if (tokenName == "eth") return "9999";
//     final DeployedContract tokenContract =
//         await ethService.loadTokenContract(tokenName);
//     final res = await ethService.query(tokenContract, "allowance",
//         [await address, await ethService.getTokenAddr(tokenName, "vaults")]);
//     return EthereumService.fromWei(res.single, tokenName);
//   }
//
//   Future<String?> getLockedAmount(contractName) async {
//     final DeployedContract contract = await ethService.loadContractWithGivenAddress(
//         "vaults", await ethService.getTokenAddr(contractName, "vaults"));
// //    TODO
//   }
//
//   Future<String> getTotalStakedToken(stakedToken) async {
//     final DeployedContract tokenContract =
//         await ethService.loadTokenContract(stakedToken);
//     final result = await ethService.query(tokenContract, "balanceOf",
//         [ethService.getTokenAddrHex(stakedToken, "staking")]);
//     return EthereumService.fromWei(result.single, stakedToken);
//   }
//
//   Future<List<String>> getSandAndTimeAmount(contractName, amount) async {
//     final DeployedContract contract = await ethService.loadContractWithGivenAddress(
//         "vaults", await ethService.getTokenAddrHex(contractName, "vaults"));
//     final result = await ethService.query(contract, "sealedAndTimeAmount",
//         [await address, EthereumService.getWei(amount, contractName)]);
//     return [
//       EthereumService.fromWei(result[0], 'ether'),
//       EthereumService.fromWei(result[1], 'ether')
//     ];
//   }
//
//   Future<String> approve(tokenName, Gas gas) async {
//     if (tokenName == "eth") return "9999999";
//     final amount = "10000000000000000000000000000";
//     final DeployedContract tokenContract =
//         await ethService.loadTokenContract(tokenName);
//     final res = await ethService.submit(
//         await credentials,
//         tokenContract,
//         "approve",
//         [
//           await ethService.getTokenAddr(tokenName, "vaults"),
//           EthereumService.getWei(amount, tokenName)
//         ],
//         gas: gas);
//     return res;
//   }
//
//   Future<Transaction?> makeApproveTransaction(tokenName) async {
//     if (!checkWallet()) {
//       return null;
//     }
//     final amount = "10000000000000000000000000000";
//     final DeployedContract tokenContract =
//         await ethService.loadTokenContract(tokenName);
//     final res = await ethService
//         .makeTransaction(await credentials, tokenContract, "approve", [
//       await ethService.getTokenAddr(tokenName, "vaults"),
//       EthereumService.getWei(amount, tokenName)
//     ]);
//     return res;
//   }
//
//   Future<Transaction?> makeLockTransaction(contractName, amount) async {
//     if (!checkWallet()) {
//       return null;
//     }
//     if (contractName == "eth") {
//       final DeployedContract contract = await ethService.loadContractWithGivenAddress(
//           "vaultsEth", await ethService.getTokenAddr(contractName, "vaults"));
//       return await ethService.makeTransaction(
//           await credentials, contract, "lock", [],
//           value: amount);
//     }
//     final DeployedContract contract = await ethService.loadContractWithGivenAddress(
//         "vaults", await ethService.getTokenAddr(contractName, "vaults"));
//     return await ethService.makeTransaction(await credentials, contract, "lock",
//         [EthereumService.getWei(amount, contractName)]);
//   }
//
//   Future<String> lock(contractName, amount, Gas gas) async {
//     if (!checkWallet()) {
//       return "0";
//     }
//     if (contractName == "eth") {
//       final DeployedContract contract = await ethService.loadContractWithGivenAddress(
//           "vaultsEth", await ethService.getTokenAddr(contractName, "vaults"));
//       return await ethService.submit(await credentials, contract, "lock", [],
//           value: amount, gas: gas);
//     }
//     final DeployedContract contract = await ethService.loadContractWithGivenAddress(
//         "vaults", await ethService.getTokenAddr(contractName, "vaults"));
//     return await ethService.submit(await credentials, contract, "lock",
//         [EthereumService.getWei(amount, contractName)],
//         gas: gas);
//   }
// }
