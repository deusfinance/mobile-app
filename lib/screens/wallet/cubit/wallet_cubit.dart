import 'dart:async';
import 'dart:math';

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/transaction.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/screens/wallet/cubit/wallet_state.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/wallet_service.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3dart/web3dart.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitialState());

  init({WalletState? walletState}) async {
    if (walletState != null) {
      emit(walletState);
    } else {
      emit(WalletLoadingState(state));
      state.database = await AppDatabase.getInstance();
      state.database!.chainDao.insertDefaultChains();
      state.chains = getChainsList();
      await setSelectedChain(Statics.eth);
      emit(WalletPortfilioState(state));
    }
  }
  Stream<List<WalletAsset>> getWalletAssetsStream() {
    Stream<List<WalletAsset>> stream = getWalletAssetsStreamFromDB(state
        .database!.walletAssetDao
        .getAllWalletAssetsStream(state.selectedChain?.id ?? 0));
    return stream;
  }

  Stream<List<WalletAsset>> getWalletAssetsStreamFromDB(
      Stream<List<WalletAsset>> source) async* {
    List<WalletAsset> walletAssets = [];
    await for (var ts in source) {
      walletAssets = await getWalletAssetsInfo(ts);
      yield walletAssets;
    }
    if (walletAssets.isNotEmpty) yield walletAssets;
  }

  Future<List<WalletAsset>> getWalletAssetsInfo(List<WalletAsset> walletAssets) async {
    for (int i = 0; i < walletAssets.length; i += 1) {
      walletAssets[i].balance =
      await (state.walletService!.getTokenBalance(walletAssets[i]));
    }
    if (state.selectedChain != null) {
      WalletAsset? walletAsset;
      switch (state.selectedChain!.id) {
        case 1:
          walletAsset = Statics.eth.mainAsset;
          break;
        case 100:
          walletAsset = Statics.xdai.mainAsset;
          break;
        case 56:
          walletAsset = Statics.bsc.mainAsset;
          break;
        case 128:
          walletAsset = Statics.heco.mainAsset;
          break;
        case 137:
          walletAsset = Statics.matic.mainAsset;
          break;
        default:
          walletAsset = new WalletAsset(
              chainId: state.selectedChain!.id,
              tokenAddress: Statics.zeroAddress,
              tokenSymbol: state.selectedChain!.currencySymbol ?? "ETH",
              tokenName: state.selectedChain!.currencySymbol ?? "ETH");
      }
      if (walletAsset != null) {
        walletAsset.balance = await (state.walletService!.getEtherBalance());
        walletAssets.insert(0, walletAsset);
      }
    }
    return walletAssets;
  }

  Future<void> test()async{
    DbTransaction transaction;
    Future.delayed(Duration(seconds: 2),() async {
      transaction = new DbTransaction(
          chainId: state.selectedChain?.id??0,
          hash: "",
          type: TransactionType.BUY.index,
          title: "test");
      List<int> ids = await state.database!.transactionDao
          .insertDbTransaction([transaction]);
      transaction.id = ids[0];
      print("hello");
      Future.delayed(Duration(seconds: 2),() async {
        transaction.title = "asdca";
        await state.database!.transactionDao
            .updateDbTransactions([transaction]);
        print("helloasdasda");
      });
    });

  }

  Stream<List<DbTransaction>> getTransactionsStream() {
    Stream<List<DbTransaction>> stream = getTransactionsStreamFromDB(state
        .database!.transactionDao
        .getAllDbTransactions(state.selectedChain?.id ?? 0));
    return stream;
  }
  // Stream<List<DbTransaction>> getTransactionsStreamFromDB(List<DbTransaction> source) async* {
  //   List<DbTransaction> transactions = [];
  //   transactions = await getTransactionsInfo(source);
  //   yield transactions;
  // }

  Stream<List<DbTransaction>> getTransactionsStreamFromDB(
      Stream<List<DbTransaction>> source) async* {
    List<DbTransaction> transactions = [];
    await for (var ts in source) {
      transactions = await getTransactionsInfo(ts);
      yield transactions;
    }
    if (transactions.isNotEmpty) yield transactions;
  }

  Future<List<DbTransaction>> getTransactionsInfo(
      List<DbTransaction> transactions) async {
    for (int i = 0; i < transactions.length; i += 1) {
      if(transactions[i].hash.isNotEmpty) {
        TransactionInformation info =
        await state.walletService!.getTransactionInfo(transactions[i].hash);
        transactions[i].nonce = info.nonce;
        transactions[i].blockNum = info.blockNumber;
        transactions[i].data = info.input;
        transactions[i].value = info.value;
        transactions[i].from = info.from;
        transactions[i].to = info.to;
        transactions[i].gasPrice = info.gasPrice;
        transactions[i].maxGas = info.gas;
      }
    }
    return transactions;
  }

  Stream<List<Chain>> getChainsList() {
    return state.database!.chainDao.getAllChains();
  }

  void changeTab(int i) {
    if (i == 0)
      emit(WalletPortfilioState(state));
    else
      emit(WalletManageTransState(state));
  }

  Future<void> addChain(Chain chain) async {
    emit(WalletLoadingState(state));
    List<int> ids = await state.database!.chainDao.insertChain([chain]);
    if (ids.isNotEmpty) {
      state.selectedChain = chain;
      await setSelectedChain(chain);
    }
    emit(WalletPortfilioState(state));
  }

  Future<void> deleteChain(Chain chain) async {
    emit(WalletLoadingState(state));
    if (chain.id != 1) {
      state.database!.chainDao.deleteChains([chain]);
      await setSelectedChain(Statics.eth);
    }
    emit(WalletPortfilioState(state));
  }

  Future<void> setSelectedChain(Chain chain) async {
    emit(WalletLoadingState(state));
    state.selectedChain = chain;
    state.walletService = new WalletService(state.selectedChain ?? Statics.eth,
        locator<ConfigurationService>().getPrivateKey()!);
    emit(WalletPortfilioState(state));
  }

  Future<void> addWalletAsset(WalletAsset walletAsset) async {
    emit(WalletLoadingState(state));
    List<int> ids =
        await state.database!.walletAssetDao.insertWalletAsset([walletAsset]);
    emit(WalletPortfilioState(state));
  }

  Future<void> updateChain(Chain chain) async {
    emit(WalletLoadingState(state));
    int id = await state.database!.chainDao.updateChains([chain]);
    await setSelectedChain(chain);
    emit(WalletPortfilioState(state));
  }

  Future<void> deleteWalletAsset(WalletAsset walletAsset) async {
    emit(WalletLoadingState(state));
    state.database!.walletAssetDao.deleteWalletAsset([walletAsset]);
    emit(WalletPortfilioState(state));
  }

  Transaction makeTransactionWithInfo(DbTransaction transaction) {
    Transaction t = new Transaction(
        from: transaction.from,
        to: transaction.to,
        value: transaction.value,
        data: transaction.data,
        gasPrice: transaction.gasPrice,
        nonce: transaction.nonce,
        maxGas: transaction.maxGas);
    return t;
  }

  Future<Transaction> makeCancelTransaction(DbTransaction transaction) async {
    Gas gas = new Gas();
    gas.nonce = transaction.nonce;
    gas.gasLimit = transaction.maxGas;
    gas.gasPrice = ((transaction.gasPrice?.getInWei??BigInt.zero) / BigInt.from(pow(10,18))).toDouble();

    Transaction t = await state.walletService!.makeEtherTransaction(
        await state.walletService!.credentials,
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
        recAddress: transaction.from!.hex,
        gas: gas);
    return t;
  }

  Future<String> sendTransaction(Gas? gas, Transaction transaction) async {
    if (gas != null) {
      Transaction t = new Transaction(
          from: transaction.from,
          to: transaction.from,
          value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
          data: transaction.data,
          gasPrice:
              EtherAmount.fromUnitAndValue(EtherUnit.gwei, gas.getGasPrice()),
          maxGas: gas.gasLimit > 0 ? gas.gasLimit : 650000,
          nonce: transaction.nonce);
      var res = await state.walletService!.submit(transaction: t);
      return res;
    } else {
      return "";
    }
  }
}
