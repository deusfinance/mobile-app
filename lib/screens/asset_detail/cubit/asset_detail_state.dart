
import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/service/wallet_service.dart';
import 'package:equatable/equatable.dart';

abstract class AssetDetailState extends Equatable {
  WalletAsset walletAsset;
  AppDatabase? database;
  Chain chain;
  WalletService? walletService;

  AssetDetailState.init(this.walletAsset, this.chain);
  AssetDetailState.copy(AssetDetailState state)
      : database = state.database,
        chain = state.chain,
        walletService = state.walletService,
        walletAsset = state.walletAsset;

  @override
  List<Object?> get props => [walletAsset];
}

class AssetDetailInitialState extends AssetDetailState {
  AssetDetailInitialState(WalletAsset walletAsset, Chain chain) : super.init(walletAsset, chain);
}

class AssetDetailLoadingState extends AssetDetailState {
  AssetDetailLoadingState(AssetDetailState state) : super.copy(state);
}

class AssetDetailErrorState extends AssetDetailState {
  AssetDetailErrorState(AssetDetailState state) : super.copy(state);
}

class AssetDetailLoadedState extends AssetDetailState {
  AssetDetailLoadedState(AssetDetailState state) : super.copy(state);
}