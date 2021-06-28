
import 'dart:convert';

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class WalletService{
  Chain chain;
  late String ethUrl;
  late Client httpClient;
  late Web3Client ethClient;

  String privateKey;

  static const ABIS_PATH = "assets/deus_data/abis.json";

  WalletService(this.chain, this.privateKey) {
    httpClient = new Client();
    ethClient = new Web3Client(chain.RPC_url, httpClient);
  }

  Future<DeployedContract> loadContractWithGivenAddress(
      String contractName, contractAddress) async {
    String allAbis = await rootBundle.loadString(ABIS_PATH);
    final decodedAbis = jsonDecode(allAbis);
    final abiCode = jsonEncode(decodedAbis[contractName]);
    return DeployedContract(
        ContractAbi.fromJson(abiCode, contractName), contractAddress);
  }

  Future<String> getTokenBalance(WalletAsset walletAsset) async {
    DeployedContract tokenContract = await loadContractWithGivenAddress("token", EthereumAddress.fromHex(walletAsset.tokenAddress));

    final res =
    await query(tokenContract, "balanceOf", [await address]);
    return fromWei(res.single, walletAsset);
  }

  Future<List<dynamic>> query(DeployedContract contract, String functionName, List<dynamic> args) async {
    final ethFunction = contract.function(functionName);
    final data = await ethClient.call(contract: contract, function: ethFunction, params: args);
    return data;
  }

  Future<Credentials> credentialsForKey(String privateKey) {
    return ethClient.credentialsFromPrivateKey(privateKey);
  }

  Future<Credentials> get credentials =>
      credentialsForKey(privateKey);

  Future<EthereumAddress> get address async =>
      (await credentials).extractAddress();

  static BigInt getWei(String amount, WalletAsset walletAsset) {
    int max = walletAsset.tokenDecimal??18;
    if (amount == "") {
      amount = "0.0";
    }
    int dotIndex = amount.indexOf(".");
    var ans;

    if (dotIndex == -1) {
      ans = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount)
          .getInWei
          .toString();
    } else {
//      TODO check larger than 18
      int zerosNo = 18 - (amount.length - dotIndex - 1);
      amount = amount.replaceAll(".", "");
      if (zerosNo < 0) {
        amount = amount.substring(0, amount.length + zerosNo - 1);
      } else {
        for (var i = 0; i < zerosNo; i++) {
          amount += "0";
        }
      }
      ans = amount;
    }
    ans = ans.substring(0, ans.length - (18 - max));
    return BigInt.parse(ans.toString());
  }

  static String fromWei(BigInt value, WalletAsset walletAsset) {
    int max = walletAsset.tokenDecimal??18;
    String ans = value.toString();

    while (ans.length < max) {
      ans = "0" + ans;
    }
    ans = ans.substring(0, ans.length - max) +
        "." +
        ans.substring(ans.length - max);
    if (ans[0] == ".") {
      ans = "0" + ans;
    }
    return ans;
  }


}