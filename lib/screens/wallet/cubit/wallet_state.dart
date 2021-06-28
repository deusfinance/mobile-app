

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/service/wallet_service.dart';
import 'package:equatable/equatable.dart';

abstract class WalletState extends Equatable {
  AppDatabase? database;
  Stream<List<Chain>> chains;
  Chain? selectedChain;
  WalletService? walletService;

  List<WalletAsset> walletAssets;

  WalletState.init():
      walletAssets = new List.empty(),
      chains = new Stream.empty();

  WalletState.copy(WalletState state):
      walletAssets = state.walletAssets,
      database = state.database,
      walletService = state.walletService,
      selectedChain = state.selectedChain,
      chains = state.chains;

  @override
  List<Object?> get props => [chains, walletAssets, selectedChain];

}

class WalletInitialState extends WalletState{
  WalletInitialState(): super.init();

}

class WalletLoadingState extends WalletState{
  WalletLoadingState(WalletState state): super.copy(state);
}

class WalletErrorState extends WalletState{
  WalletErrorState(WalletState state): super.copy(state);
}

class WalletPortfilioState extends WalletState{
  WalletPortfilioState(WalletState state): super.copy(state);
}

class WalletManageTransState extends WalletState{
  WalletManageTransState(WalletState state): super.copy(state);
}