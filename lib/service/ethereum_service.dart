//TODO (@CodingDavid8): Merge address_service.dart and ethereum_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/token.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

/// General service in order to connect to the Ethereum blockchain.
class EthereumService {
  int chainId;
  String ethUrl;
  Client httpClient;
  Web3Client ethClient;

  static const TOKEN_MAX_DIGITS = {
    "wbtc": 8,
    "usdt": 6,
    "usdc": 6,
    "coinbase": 18,
    "dea": 18,
    "deus": 18,
    "dai": 18,
    "eth": 18,
  };

  static Map<String, Token> addressToTokenMap = new Map();

  static const ABIS_PATH = "assets/deus_data/abis.json";
  static const ADDRESSES_PATH = "assets/deus_data/addresses.json";
  //TODO (@CodingDavid8): Create Network class.
  static const NETWORK_NAMES = {
    1: "Mainnet",
    3: "Ropsten",
    4: "Rinkeby",
    42: "Kovan",
    100: "xDAI",
  };

  String get networkName => NETWORK_NAMES[this.chainId];

  // IMPORTANT use http instead of wss infura endpoint, web3dart not supporting wss yet
  String get INFURA_URL {
    if(this.chainId == 100){
      return 'https://rpc.xdaichain.com/';
    }else{
      return 'https://' + networkName + '.infura.io/v3/cf6ea736e00b4ee4bc43dfdb68f51093';
    }
  }

  EthereumService(this.chainId) {
    httpClient = new Client();
    ethClient = new Web3Client(INFURA_URL, httpClient);
    makeAddrDict();
  }

  makeAddrDict() async {
    String allAddresses = await rootBundle.loadString(ADDRESSES_PATH);
    final decodedAddresses = jsonDecode(allAddresses);
    final tokensAddresses = decodedAddresses["token"];
    tokensAddresses.forEach((key, value) {
      Token t = _getTokenObjectByName(key);
      if (t != null) {
        addressToTokenMap.addEntries(
            [MapEntry<String, Token>(value["1"].toString().toLowerCase(), t)]);
        addressToTokenMap.addEntries(
            [MapEntry<String, Token>(value["4"].toString().toLowerCase(), t)]);
      }
    });
  }

  Token _getTokenObjectByName(String tokenName) {
    if (tokenName == "weth") {
      tokenName = "eth";
    }
    for (var i = 0; i < CurrencyData.allForDict.length; i++) {
      if (CurrencyData.allForDict[i].getTokenName() == tokenName) {
        return CurrencyData.allForDict[i];
      }
    }
    return null;
  }

  static BigInt getWei(String amount, [String token = "eth"]) {
    var max =
        TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
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
//      TODO check largt than 18
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

  static String fromWei(BigInt value, [String token = "eth"]) {
    var max =
        TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
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

  static String formatDouble(String value, [int doubleNo = 9]) {
    int dotIndex = value.indexOf(".");
    if (dotIndex >= 0) {
      while (value.endsWith("0")) {
        if (value.length > 2) {
          value = value.substring(0, value.length - 1);
        }
      }
      int float = value.length - dotIndex - 1;
      if (float > doubleNo) {
        value = value.substring(0, dotIndex + doubleNo + 1);
      }
    }
    return value;
  }

  Future<DeployedContract> loadTokenContract(String tokenName) async {
    String allAbis = await rootBundle.loadString(ABIS_PATH);

    final decodedAbis = jsonDecode(allAbis);
    final abiCode = jsonEncode(decodedAbis["token"]);

    final contractAddress = await getTokenAddr(tokenName, "token");
    return DeployedContract(
        ContractAbi.fromJson(abiCode, tokenName), contractAddress);
  }

  Future<DeployedContract> loadContractWithGivenAddress(
      String contractName, contractAddress) async {
    String allAbis = await rootBundle.loadString(ABIS_PATH);
    final decodedAbis = jsonDecode(allAbis);
    final abiCode = jsonEncode(decodedAbis[contractName]);
    return DeployedContract(
        ContractAbi.fromJson(abiCode, contractName), contractAddress);
  }

  Future<DeployedContract> loadContract(String contractName) async {
    String allAbis = await rootBundle.loadString(ABIS_PATH);
    final decodedAbis = jsonDecode(allAbis);
    final abiCode = jsonEncode(decodedAbis[contractName]);
    final contractAddress = await getContractAddress(contractName);
    return DeployedContract(ContractAbi.fromJson(abiCode, contractName), contractAddress);
  }

  // will probably throw error since addresses is not complete
  Future<EthereumAddress> getContractAddress(String contractName) async {
    String allAddresses = await rootBundle.loadString(ADDRESSES_PATH);
    final decodedAddresses = jsonDecode(allAddresses);
    final hexAddress = decodedAddresses[contractName][chainId.toString()];
    return EthereumAddress.fromHex(hexAddress);
  }

  Future<EthereumAddress> getTokenAddr(String tokenName, String type) async {
    String allAddresses = await rootBundle.loadString(ADDRESSES_PATH);
    final decodedAddresses = jsonDecode(allAddresses);
    final hexAddress = decodedAddresses[type][tokenName][chainId.toString()];
    return EthereumAddress.fromHex(hexAddress);
  }

  Future<String> getTokenAddrHex(String tokenName, String type) async {
    return (await getTokenAddr(tokenName, type)).hex.toLowerCase();
  }

  Future<EthereumAddress> getAddr(String tokenName) async {
    String allAddresses = await rootBundle.loadString(ADDRESSES_PATH);
    final decodedAddresses = jsonDecode(allAddresses);
    final hexAddress = decodedAddresses[tokenName][chainId.toString()];
    return EthereumAddress.fromHex(hexAddress);
  }

  Future<String> getAddrHex(String tokenName) async {
    return (await getAddr(tokenName)).hex.toLowerCase();
  }

  Future<EtherAmount> getEtherBalance(Credentials credentials) async {
    return await ethClient.getBalance(await credentials.extractAddress());
  }

  /// submit a tx from the supplied [credentials]
  /// calls deploayed [contract] with the function [functionName] supplying all [args] in order of appearence in the api
  /// returns a [String] containing the tx hash which can be used to acquire further information about the tx
  Future<String> submit(Credentials credentials, DeployedContract contract,
      String functionName, List<dynamic> args,
      {EtherAmount value, Gas gas}) async {
    Transaction transaction = await makeTransaction(credentials, contract, functionName, args,
        gas: gas, value: value);
    var result = await ethClient.sendTransaction(
        credentials,
        transaction,
        chainId: chainId);
    return result;
  }


  Future<String> sendTransaction(
      Credentials credentials, Transaction transaction) async {
    var result = await ethClient.sendTransaction(credentials, transaction,
        chainId: chainId);
    return result;
  }

  Future<Transaction> makeTransaction(Credentials credentials,
      DeployedContract contract, String functionName, List<dynamic> args,
      {EtherAmount value, Gas gas}) async {
    final ethFunction = contract.function(functionName);
    Transaction transaction;
    if (gas != null && gas.nonce > 0) {
      if(value!=null)
        transaction = Transaction.callContract(
            from: await credentials.extractAddress(),
            contract: contract,
            function: ethFunction,
            parameters: args,
            gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice()),
            maxGas: gas.gasLimit > 0 ? gas.gasLimit : 650000,
            nonce: gas.nonce,
            value: value);
      else
        transaction = Transaction.callContract(
            from: await credentials.extractAddress(),
            contract: contract,
            function: ethFunction,
            parameters: args,
            gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice()),
            maxGas: gas.gasLimit > 0 ? gas.gasLimit : 650000,
            nonce: gas.nonce);

    } else {
      if(value!=null)
        transaction = Transaction.callContract(
            from: await credentials.extractAddress(),
            contract: contract,
            function: ethFunction,
            parameters: args,
            gasPrice: gas != null
                ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice())
                : EtherAmount.fromUnitAndValue(EtherUnit.gwei, 1),
            maxGas: gas != null && gas.gasLimit > 0 ? gas.gasLimit : 650000,
            value: value);
      else
        transaction = Transaction.callContract(
            from: await credentials.extractAddress(),
            contract: contract,
            function: ethFunction,
            parameters: args,
            gasPrice: gas != null
                ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice())
                : EtherAmount.fromUnitAndValue(EtherUnit.gwei, 1),
            maxGas: gas != null && gas.gasLimit > 0 ? gas.gasLimit : 650000);
    }

    return transaction;
  }

  Future<List<dynamic>> query(DeployedContract contract, String functionName, List<dynamic> args) async {
    final ethFunction = contract.function(functionName);
    final data = await ethClient.call(contract: contract, function: ethFunction, params: args);
    return data;
  }

  /// Function to get receipt
  Future<TransactionReceipt> getTransactionReceipt(String txHash) async {
    return await ethClient.getTransactionReceipt(txHash);
  }

  Stream<TransactionReceipt> pollTransactionReceipt(String txHash,
      {int pollingTimeMs = 1500}) async* {
    StreamController<TransactionReceipt> controller = StreamController();
    Timer timer;

    Future<void> tick() async {
      var receipt = await getTransactionReceipt(txHash);
      if (receipt != null && !controller.isClosed) {
        timer?.cancel();
        controller.add(receipt);
        controller.close();
      }
    }

    // start first tick before timer if the receipt is available immediately
    tick();

    if (!controller.isClosed) {
      Timer.periodic(Duration(milliseconds: pollingTimeMs), (timer) async {
        await tick();
      });
    }

    yield* controller.stream;
  }

  Future<Credentials> credentialsForKey(String privateKey) {
    return ethClient.credentialsFromPrivateKey(privateKey);
  }

  EthPrivateKey generateKeyPair() {
    var rng = new Random.secure();
    EthPrivateKey random = EthPrivateKey.createRandom(rng);
    return random;
  }

// void addBlockListener(listener){
//   ethClient.addedBlocks(listener);
//   ethClient.
// }

//  (@kazem)
// synthetics
  Future<String> getStakingAddrHex(String tokenName) async {
    return (await getStakingAddr(tokenName)).hex;
  }

  Future<EthereumAddress> getStakingAddr(String tokenName) async {
    String allAddresses = await rootBundle.loadString(ADDRESSES_PATH);
    final decodedAddresses = jsonDecode(allAddresses);
    final hexAddress = decodedAddresses["staking"][tokenName][chainId.toString()];
    return EthereumAddress.fromHex(hexAddress);
  }
}
