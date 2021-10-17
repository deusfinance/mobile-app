// import 'package:web3dart/credentials.dart';
// import 'package:web3dart/web3dart.dart';
//
// import 'ethereum_service.dart';
//
// class MuskService {
//   static const TOKEN_MAX_DIGITS = {
//     "wbtc": 8,
//     "usdt": 6,
//     "usdc": 6,
//     "coinbase": 18,
//     "dea": 18,
//     "deus": 18,
//     "dai": 18,
//     "eth": 18,
//     "bakkt": 18,
//     "spcx": 18,
//   };
//   final EthereumService ethService;
//   final String privateKey;
//
//   MuskService({required this.ethService, required this.privateKey});
//
//   Future<Credentials> get credentials =>
//       ethService.credentialsForKey(privateKey);
//
//   Future<EthereumAddress> get address async =>
//       (await credentials).extractAddress();
//
//   Future<String> getTokenBalance(String tokenName) async {
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
//   Future<String> getAllowances(String token) async {
//     if (token == "eth") return "99999";
//
//     final DeployedContract tokenContract = await ethService.loadTokenContract(token);
//     final res = await ethService.query(tokenContract, "allowance",
//         [await address, ethService.getAddrHex("spcx_swap_contract")]);
//     return EthereumService.fromWei(res.single, token);
//   }
//
//   Future<String> approve(String token) async {
//     const String amount = "10000000000000000000000000";
//
//     final DeployedContract tokenContract = await ethService.loadTokenContract(token);
//     final res = await ethService.submit(
//         await credentials, tokenContract, "approve", [
//       await ethService.getAddrHex("spcx_swap_contract"),
//       EthereumService.getWei(amount, token)
//     ]);
//     return res;
//   }
//
//   Future<String> swapTokens(String fromToken, String toToken, String tokenAmount) async {
//     final DeployedContract contract = await ethService.loadContractWithGivenAddress(
//         "bakkt_swap_contract",
//         EthereumAddress.fromHex(await ethService.getAddrHex("spcx_swap_contract")));
//     if (fromToken == "spcx" && toToken == "dea") {
//       final res = await ethService.query(
//           contract, "calculateSaleReturn", [EthereumService.getWei(tokenAmount, toToken)]);
//       final deaAmount = EthereumService.fromWei(res.single, toToken);
// //      TODO
// //      return await ethService.submit(await credentials, contract, "sell", [EthereumService.getWei(tokenAmount, fromToken), getWei(BigInt.from(0.95 * deaAmount), toToken)]);
//       return deaAmount;
//     } else if (fromToken == "dea" && toToken == "spcx") {
//       final res = await ethService
//           .query(contract, "calculatePurchaseReturn", [EthereumService.getWei(tokenAmount)]);
//       final spcxAmount = EthereumService.fromWei(res[0], toToken);
//       //      TODO
//      // return await ethService.submit(await credentials, contract, "buy", [EthereumService.getWei(BigInt.from(0.95 * BigInt.parse(spcxAmount)).toString(), toToken), getWei(tokenAmount, toToken)]);
//       return spcxAmount;
//     }
//     return "0";
//   }
//
//   Future<String?> getAmountsOut(String fromToken, String toToken, String amountIn) async {
//     final DeployedContract spcxContract =
//         await ethService.loadContractWithGivenAddress(
//             "sps", EthereumAddress.fromHex(await ethService.getAddrHex("spcx_swap_contract")));
//     if (fromToken == "spcx" && toToken == "dea") {
//       final res = await ethService.query(
//           spcxContract, "calculateSaleReturn", [EthereumService.getWei(amountIn, fromToken)]);
//       return EthereumService.fromWei(res[0], toToken);
//     } else if (fromToken == "dea" && toToken == "spcx") {
//       final res = await ethService.query(spcxContract, "calculatePurchaseReturn",
//           [EthereumService.getWei(amountIn, fromToken)]);
//       return EthereumService.fromWei(res[0], toToken);
//     }
//   }
// }
