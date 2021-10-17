// import 'dart:math';
//
// import 'package:flutter/cupertino.dart';
// import 'package:web3dart/web3dart.dart';
//
// import 'ethereum_service.dart';
//
// class CoinBaseService {
//   static const TOKEN_MAX_DIGITS = {
//     "coinbase": 18,
//     "deus": 18,
//   };
//
//   final EthereumService ethService;
//   final String privateKey;
//
//   CoinBaseService({required this.ethService, required this.privateKey});
//
//   Future<Credentials> get credentials =>
//       ethService.credentialsForKey(privateKey);
//
//   Future<EthereumAddress> get address async =>
//       (await credentials).extractAddress();
//
//   BigInt getWei(BigInt amount, [String token = "eth"]) {
//     final max =
//         TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
//     // let value = typeof number === "string" ? parseFloat(number).toFixed(18) : number.toFixed(18)
//     var ans = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount)
//         .getInWei
//         .toString();
//     ans = ans.substring(0, ans.length - (18 - max!));
//     return BigInt.parse(ans.toString());
//   }
//
//   String fromWei(BigInt value, String token) {
//     final max =
//         TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
//     String ans = value.toString();
//
//     while (ans.length < max!) {
//       ans = "0" + ans;
//     }
//     ans = ans.substring(0, ans.length - max) +
//         "." +
//         ans.substring(ans.length - max);
//     if (ans[0] == ".") {
//       ans = "0" + ans;
//     }
//     return ans;
//   }
//
//   Future<String> getTokenBalance(tokenName) async {
//     if (!this.checkWallet()) return "0";
//
//     if (tokenName == "eth") {
//       return this.getEtherBalance();
//     }
//     final tokenContract = await ethService.loadTokenContract(tokenName);
//     final result =
//         await ethService.query(tokenContract, "balanceOf", [await address]);
//
//     return this.fromWei(result.single, tokenName);
//   }
//
//   Future<String> getEtherBalance() async {
//     if (!this.checkWallet()) return "0";
//
//     return (await ethService.getEtherBalance(await credentials))
//         .getInEther
//         .toString();
//   }
//
//   Future<String> getAllowances(tokenName) async {
//     if (!checkWallet()) {
//       return "0";
//     }
//     if (tokenName == "eth" || tokenName == "coinbase") return "99999";
//     final DeployedContract tokenContract =
//         await ethService.loadTokenContract(tokenName);
//     final res = await ethService.query(tokenContract, "allowance",
//         [await address, ethService.getAddrHex("coinbase_swap_contract")]);
//     return fromWei(res.single, tokenName);
//   }
//
//   Future<String> approve(tokenName) async {
//     if (!checkWallet()) {
//       return "0";
//     }
//     final amount = BigInt.from(pow(10, 25));
//     final DeployedContract tokenContract =
//         await ethService.loadTokenContract(tokenName);
//     final res = await ethService.submit(
//         await credentials, tokenContract, "approve", [
//       ethService.getAddrHex("coinbase_swap_contract"),
//       getWei(amount, tokenName)
//     ]);
//     return res;
//   }
//
//   Future<String> swapTokens(fromToken, toToken, tokenAmount) async {
//     if (!checkWallet()) {
//       return "0";
//     }
//     final DeployedContract contract = await ethService.loadContractWithGivenAddress(
//         "bakkt_swap_contract",
//         await ethService.getAddrHex("coinbase_swap_contract"));
//     if (fromToken == "coinbase" && toToken == "deus") {
//       final res = await ethService.query(
//           contract, "calculateSaleReturn", [getWei(tokenAmount, toToken)]);
//       final deusAmount = fromWei(res.single, toToken);
// //      TODO
// //      return await ethService.submit(await credentials, contract, "sell", [getWei(tokenAmount, fromToken), getWei(BigInt.from(0.95 * deusAmount), toToken)]);
//
//     } else if (fromToken == "deus" && toToken == "coinbase") {
//       final res = await ethService
//           .query(contract, "calculatePurchaseReturn", [getWei(tokenAmount)]);
//       final coinBaseAmount = fromWei(res[0], toToken);
//       //      TODO
// //      return await ethService.submit(await credentials, contract, "buy", [getWei(BigInt.from(0.95 * coinBaseAmount), toToken), getWei(tokenAmount, toToken)]);
//     }
//     return "0";
//   }
//
//   Future<String?> getAmountsOut(fromToken, toToken, amountIn) async {
//     final DeployedContract bakktContract =
//         await ethService.loadContractWithGivenAddress(
//             "sps", await ethService.getAddrHex("coinbase_swap_contract"));
//     if (fromToken == "coinbase" && toToken == "deus") {
//       final res = await ethService.query(
//           bakktContract, "calculateSaleReturn", [getWei(amountIn, fromToken)]);
//       return fromWei(res[0], toToken);
//     } else if (fromToken == "deus" && toToken == "coinbase") {
//       final res = await ethService.query(bakktContract, "calculatePurchaseReturn",
//           [getWei(amountIn, fromToken)]);
//       return fromWei(res[0], toToken);
//     }
//   }
//
//   getAmountsIn(fromToken, toToken, amountOut) {
//     return -1;
//   }
// }
