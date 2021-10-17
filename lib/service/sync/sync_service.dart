import '../../models/swap/gas.dart';
import '../../models/synthetics/contract_input_data.dart';
import '../ethereum_service.dart';
import 'package:web3dart/web3dart.dart';

abstract class SyncService {
  EthereumService ethService;
  String? privateKey;

  SyncService(this.ethService, this.privateKey);

  Future<Transaction> makeBuyTransaction(
      String tokenAddress, String amount, List<ContractInputData> oracles,
      {String? maxPrice});

  Future<Transaction> makeSellTransaction(
      String tokenAddress, String amount, List<ContractInputData> oracles);

  Future<String> getUsedCap();

  Future<String> sell(String tokenAddress, String amount,
      List<ContractInputData> oracles, Gas gas);

  Future<String> buy(String tokenAddress, String amount,
      List<ContractInputData> oracles, Gas gas,
      {String? maxPrice});

  Future<String> getTokenBalance(String tokenAddress);

  Future<Transaction> makeApproveTransaction(String tokenAddress);

  Future<String> approve(String tokenAddress, Gas gas);

  Future<String> getAllowances(String tokenAddress);

  Future<Credentials> get credentials =>
      ethService.credentialsForKey(privateKey ?? "");

  Future<EthereumAddress> get address async =>
      (await credentials).extractAddress();
}
