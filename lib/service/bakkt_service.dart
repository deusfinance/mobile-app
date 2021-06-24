import 'dart:math';

import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class BakktService {
  static const TOKEN_MAX_DIGITS = {
    "wbtc": 8,
    "usdt": 6,
    "usdc": 6,
    "coinbase": 18,
    "dea": 18,
    "deus": 18,
    "dai": 18,
    "eth": 18,
    "bakkt": 18,
    "spcx": 18,
  };
  final EthereumService ethService;
  final String privateKey;

  BakktService({required this.ethService, required this.privateKey});

  Future<Credentials> get credentials => ethService.credentialsForKey(privateKey);

  Future<EthereumAddress> get address async => (await credentials).extractAddress();

  bool checkWallet() {
    return ethService != null && this.privateKey != null;
  }

  BigInt getWei(BigInt amount, [String token = "eth"]) {
    var max = TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
    // let value = typeof number === "string" ? parseFloat(number).toFixed(18) : number.toFixed(18)
    var ans = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount).getInWei.toString();
    ans = ans.substring(0, ans.length - (18 - max!));
    return BigInt.parse(ans.toString());
  }

  String fromWei(BigInt value, String token) {
    var max = TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
    String ans = value.toString();

    while (ans.length < max!) {
      ans = "0" + ans;
    }
    ans = ans.substring(0, ans.length - max) + "." + ans.substring(ans.length - max);
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

    return this.fromWei(result.single, tokenName);
  }

  Future<String> getEtherBalance() async {
    if (!this.checkWallet()) return "0";

    return (await ethService.getEtherBalance(await credentials)).getInEther.toString();
  }

  Future<String> getAllowances(token) async {
    if (!checkWallet()) return "0";
    if (token == "eth") return "99999";

    DeployedContract tokenContract = await ethService.loadTokenContract(token);
    final res = await ethService
        .query(tokenContract, "allowance", [await address, ethService.getAddrHex("bakkt_swap_contract")]);
    return fromWei(res.single, token);
  }

  Future<String> approve(token) async {
    if (!checkWallet()) {
      return "0";
    }
    var amount = BigInt.from(pow(10, 25));

    DeployedContract tokenContract = await ethService.loadTokenContract(token);
    var res = await ethService.submit(await credentials, tokenContract, "approve",
        [await ethService.getAddrHex("bakkt_swap_contract"), getWei(amount, token)]);
    return res;
  }

  Future<String> swapTokens(fromToken, toToken, tokenAmount) async {
    if (!checkWallet()) {
      return "0";
    }
    DeployedContract contract = await ethService.loadContractWithGivenAddress(
        "bakkt_swap_contract", await ethService.getAddrHex("bakkt_swap_contract"));
    if (fromToken == "bakkt" && toToken == "deus") {
      var res = await ethService.query(contract, "calculateSaleReturn", [getWei(tokenAmount, toToken)]);
      var deusAmount = fromWei(res.single, toToken);
//      TODO
//      return await ethService.submit(await credentials, contract, "sell", [getWei(tokenAmount, fromToken), getWei(BigInt.from(0.95 * deusAmount), toToken)]);

    } else if (fromToken == "deus" && toToken == "bakkt") {
      var res = await ethService.query(contract, "calculatePurchaseReturn", [getWei(tokenAmount)]);
      var bakktAmount = fromWei(res[0], toToken);
      //      TODO
//      return await ethService.submit(await credentials, contract, "buy", [getWei(BigInt.from(0.95 * bakktAmount), toToken), getWei(tokenAmount, toToken)]);
    }
    return "0";
  }

  Future<String?> getAmountsOut(fromToken, toToken, amountIn) async {
    DeployedContract contract =
        await ethService.loadContractWithGivenAddress("sps", await ethService.getAddrHex("bakkt_swap_contract"));
    if (fromToken == "bakkt" && toToken == "deus") {
      var res = await ethService.query(contract, "calculateSaleReturn", [getWei(amountIn, fromToken)]);
      return fromWei(res[0], toToken);
    } else if (fromToken == "deus" && toToken == "bakkt") {
      var res = await ethService.query(contract, "calculatePurchaseReturn", [getWei(amountIn, fromToken)]);
      return fromWei(res[0], toToken);
    }
  }

  getAmountsIn(fromToken, toToken, amountOut) {
    return -1;
  }

  Future<String> getWithdrawableAmount() async {
    if (!checkWallet()) return "0";
    DeployedContract automaticMarketMakerContract = await ethService.loadContract("amm");
    final amount = await ethService.query(automaticMarketMakerContract, "payments", [await address]);
    return fromWei(amount.first, "ether");
  }

  Future<String> withdrawPayment() async {
    DeployedContract automaticMarketMakerContract = await ethService.loadContract("amm");
    return await ethService
        .submit(await credentials, automaticMarketMakerContract, "withdrawPayments", [await address]);
  }

  Future<String> approveStocks() async {
    if (!checkWallet()) {
      return "0";
    }
    var amount = BigInt.from(pow(10, 25));

    DeployedContract tokenContract = await ethService.loadTokenContract("dai");
    var res = await ethService.submit(await credentials, tokenContract, "approve",
        [await ethService.getAddrHex("stocks_contract"), getWei(amount, "ether")]);
    return res;
  }

  Future<String> getAllowancesStocks() async {
    if (!checkWallet()) return "0";

    DeployedContract tokenContract = await ethService.loadTokenContract("dai");
    final res =
        await ethService.query(tokenContract, "allowance", [await address, ethService.getAddrHex("stocks_contract")]);
    return fromWei(res.single, 'dai');
  }

  Future<String> buyStock(stockAddress, amount, ContractInputData info) async {
    if (!checkWallet()) {
      return "0";
    }
    DeployedContract contract = await ethService.loadContract("stocks_contract");
    return ethService.submit(await credentials, contract, "buyStock", [
      stockAddress,
      getWei(amount),
      info.blockNo.toString(),
      info.signs[0]!.v.toString(),
      info.signs[0]!.r,
      info.signs[0]!.s,
      info.price.toString(),
      info.fee.toString()
    ]);
  }

  Future<String> sellStock(tokenName, amount, ContractInputData info) async {
    if (!checkWallet()) {
      return "0";
    }
    String tokenAddress = await ethService.getTokenAddrHex(tokenName, "token");
    DeployedContract contract = await ethService.loadContract("stocks_contract");
    return ethService.submit(await credentials, contract, "sellStock", [
      tokenAddress,
      getWei(amount),
      info.blockNo.toString(),
      info.signs[0]!.v.toString(),
      info.signs[0]!.r,
      info.signs[0]!.s,
      info.price.toString(),
      info.fee.toString()
    ]);
  }
}
