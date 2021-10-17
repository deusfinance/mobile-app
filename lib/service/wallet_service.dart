import 'dart:async';
import 'dart:convert';

import '../core/database/chain.dart';
import '../core/database/wallet_asset.dart';
import '../models/swap/gas.dart';
import '../statics/statics.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class WalletService {
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
      String contractName, EthereumAddress contractAddress) async {
    final String allAbis = await rootBundle.loadString(ABIS_PATH);
    final decodedAbis = jsonDecode(allAbis);
    // ignore: avoid_dynamic_calls
    final abiCode = jsonEncode(decodedAbis[contractName]);
    return DeployedContract(
        ContractAbi.fromJson(abiCode, contractName), contractAddress);
  }

  Future<String> getEtherBalance() async {
    final EtherAmount res =
        await ethClient.getBalance(await (await credentials).extractAddress());
    return fromWei(res.getInWei, null);
  }

  Future<String> getTokenBalance(WalletAsset walletAsset) async {
    try {
      final DeployedContract tokenContract = await loadContractWithGivenAddress(
          "token", EthereumAddress.fromHex(walletAsset.tokenAddress));

      final res = await query(tokenContract, "balanceOf", [await address]);
      return fromWei(res.single, walletAsset);
    } catch (e) {
      return fromWei(BigInt.zero, walletAsset);
    }
  }

  Future<List<dynamic>> query(DeployedContract contract, String functionName,
      List<dynamic> args) async {
    final ethFunction = contract.function(functionName);
    final data = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return data;
  }

  Future<Credentials> credentialsForKey(String privateKey) {
    // ignore: deprecated_member_use
    return ethClient.credentialsFromPrivateKey(privateKey);
  }

  Future<Credentials> get credentials => credentialsForKey(privateKey);

  Future<EthereumAddress> get address async =>
      (await credentials).extractAddress();

  static BigInt getWei(String amount, WalletAsset? walletAsset) {
    final int max = walletAsset != null ? walletAsset.tokenDecimal ?? 18 : 18;
    if (amount == "") {
      amount = "0.0";
    }
    final int dotIndex = amount.indexOf(".");
    String ans;

    if (dotIndex == -1) {
      ans = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount)
          .getInWei
          .toString();
    } else {
//      TODO check larger than 18
      final int zerosNo = 18 - (amount.length - dotIndex - 1);
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

  static String fromWei(BigInt value, WalletAsset? walletAsset) {
    final int max = walletAsset != null ? walletAsset.tokenDecimal ?? 18 : 18;
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

  Future<Transaction> makeTransferTransaction(
      String tokenAddress, String recAddress, String amount) async {
    if (tokenAddress == Statics.zeroAddress) {
      return await makeEtherTransaction(await credentials,
          value:
              EtherAmount.fromUnitAndValue(EtherUnit.wei, getWei(amount, null)),
          recAddress: recAddress);
    } else {
      final DeployedContract tokenContract = await loadContractWithGivenAddress(
          "token", EthereumAddress.fromHex(tokenAddress));
      return await makeTransaction(
        await credentials,
        tokenContract,
        "transfer",
        [
          EthereumAddress.fromHex(recAddress),
          EthereumService.getWei(amount),
        ],
      );
    }
  }

  Future<String> transfer(
      String tokenAddress, String recAddress, String amount, Gas gas) async {
    if (tokenAddress == Statics.zeroAddress) {
      final Transaction tr = await makeEtherTransaction(await credentials,
          value:
              EtherAmount.fromUnitAndValue(EtherUnit.wei, getWei(amount, null)),
          gas: gas,
          recAddress: recAddress);
      return await submit(transaction: tr);
    } else {
      final DeployedContract tokenContract = await loadContractWithGivenAddress(
          "token", EthereumAddress.fromHex(tokenAddress));
      return await submit(
          contract: tokenContract,
          functionName: "transfer",
          args: [
            EthereumAddress.fromHex(recAddress),
            EthereumService.getWei(amount),
          ],
          gas: gas);
    }
  }

  Future<String> submit(
      {DeployedContract? contract,
      String? functionName,
      List<dynamic>? args,
      EtherAmount? value,
      Gas? gas,
      Transaction? transaction}) async {
    if (transaction == null)
      transaction = await makeTransaction(
          await credentials, contract!, functionName!, args!,
          gas: gas, value: value);
    final result = await ethClient
        .sendTransaction(await credentials, transaction, chainId: chain.id);
    return result;
  }

  Future<String> sendTransaction(
      Credentials credentials, Transaction transaction) async {
    final result = await ethClient.sendTransaction(credentials, transaction,
        chainId: chain.id);
    return result;
  }

  Future<Transaction> makeTransaction(Credentials credentials,
      DeployedContract contract, String functionName, List<dynamic> args,
      {EtherAmount? value, Gas? gas}) async {
    final ethFunction = contract.function(functionName);
    Transaction transaction;
    if (gas != null && gas.nonce > 0) {
      if (value != null)
        transaction = Transaction.callContract(
            from: await credentials.extractAddress(),
            contract: contract,
            function: ethFunction,
            parameters: args,
            gasPrice:
                EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice()),
            maxGas: gas.gasLimit > 0 ? gas.gasLimit : 650000,
            nonce: gas.nonce,
            value: value);
      else
        transaction = Transaction.callContract(
            from: await credentials.extractAddress(),
            contract: contract,
            function: ethFunction,
            parameters: args,
            gasPrice:
                EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice()),
            maxGas: gas.gasLimit > 0 ? gas.gasLimit : 650000,
            nonce: gas.nonce);
    } else {
      if (value != null)
        transaction = Transaction.callContract(
            from: await credentials.extractAddress(),
            contract: contract,
            function: ethFunction,
            parameters: args,
            gasPrice: gas != null
                ? EtherAmount.fromUnitAndValue(
                    EtherUnit.gwei, gas.getGasPrice())
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
                ? EtherAmount.fromUnitAndValue(
                    EtherUnit.gwei, gas.getGasPrice())
                : EtherAmount.fromUnitAndValue(EtherUnit.gwei, 1),
            maxGas: gas != null && gas.gasLimit > 0 ? gas.gasLimit : 650000);
    }

    return transaction;
  }

  Future<TransactionInformation?> getTransactionInfo(String hash) async {
    TransactionInformation? info;
    info = await ethClient.getTransactionByHash(hash);
    return info;
  }

  Future<Transaction> makeEtherTransaction(Credentials credentials,
      {required EtherAmount value,
      Gas? gas,
      required String recAddress}) async {
    Transaction transaction;
    if (gas != null && gas.nonce > 0) {
      transaction = Transaction(
        from: await credentials.extractAddress(),
        to: EthereumAddress.fromHex(recAddress),
        gasPrice:
            EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice()),
        maxGas: gas.gasLimit > 0 ? gas.gasLimit : 650000,
        nonce: gas.nonce,
        value: value,
      );
    } else {
      transaction = Transaction(
        from: await credentials.extractAddress(),
        to: EthereumAddress.fromHex(recAddress),
        gasPrice: gas != null
            ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice())
            : EtherAmount.fromUnitAndValue(EtherUnit.gwei, 1),
        maxGas: gas != null && gas.gasLimit > 0 ? gas.gasLimit : 650000,
        value: value,
      );
    }

    return transaction;
  }

  /// Function to get receipt
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await ethClient.getTransactionReceipt(txHash);
  }

  Stream<TransactionReceipt> pollTransactionReceipt(String txHash,
      {int pollingTimeMs = 1500}) async* {
    final StreamController<TransactionReceipt> controller = StreamController();
    Timer? timer;

    Future<void> tick() async {
      final receipt = await getTransactionReceipt(txHash);
      if (receipt != null && !controller.isClosed) {
        timer?.cancel();
        controller.add(receipt);
        await controller.close();
      }
    }

    // start first tick before timer if the receipt is available immediately
    await tick();

    if (!controller.isClosed) {
      timer =
          Timer.periodic(Duration(milliseconds: pollingTimeMs), (timer) async {
        await tick();
      });
    }

    yield* controller.stream;
  }
}
