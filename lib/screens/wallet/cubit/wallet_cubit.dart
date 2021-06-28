import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/screens/wallet/cubit/wallet_state.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/wallet_service.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitialState());
  Chain eth = Chain(id: 1, name: "ETH", RPC_url: "https://Mainnet.infura.io/v3/cf6ea736e00b4ee4bc43dfdb68f51093");

  init() async {
    emit(WalletLoadingState(state));
    state.database =
        await $FloorAppDatabase.databaseBuilder(Statics.DB_NAME).build();
    state.database!.chainDao.insertDefaultChains();
    state.chains = getChainsList();
    state.selectedChain = eth;
    state.walletService = new WalletService(state.selectedChain ?? eth,
        locator<ConfigurationService>().getPrivateKey()!);
    state.walletAssets = await getWalletAssets();
    emit(WalletPortfilioState(state));
  }

  Future<List<WalletAsset>> getWalletAssets() async {
    List<WalletAsset> walletAssets =  await state.database!.walletAssetDao
        .getAllWalletAssets(state.selectedChain?.id ?? 0);
    walletAssets.forEach((walletAsset) async {
      walletAsset.balance = await state.walletService!.getTokenBalance(walletAsset);
    });
    return walletAssets;
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
    }
    emit(WalletPortfilioState(state));
  }

  Future<void> deleteChain(Chain chain) async {
    emit(WalletLoadingState(state));
    if (chain.id != 1) {
      state.database!.chainDao.deleteChains([chain]);
      state.selectedChain = eth;
    }
    emit(WalletPortfilioState(state));
  }

  Future<void> setSelectedChain(Chain chain) async {
    emit(WalletLoadingState(state));
    state.selectedChain = chain;
    state.walletAssets = await getWalletAssets();
    emit(WalletPortfilioState(state));
  }

  Future<void> addWalletAsset(WalletAsset walletAsset) async {
    emit(WalletLoadingState(state));
    List<int> ids =
        await state.database!.walletAssetDao.insertWalletAsset([walletAsset]);
    if (ids.isNotEmpty) {
      state.walletAssets = await getWalletAssets();
    }
    emit(WalletPortfilioState(state));
  }

  Future<void> updateChain(Chain chain) async {
    emit(WalletLoadingState(state));
    int id = await state.database!.chainDao.updateChains([chain]);
    emit(WalletPortfilioState(state));
  }
}
