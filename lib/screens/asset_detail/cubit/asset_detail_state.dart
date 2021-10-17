import '../../../core/database/chain.dart';
import '../../../core/database/database.dart';
import '../../../core/database/wallet_asset.dart';
import '../../../service/wallet_service.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
abstract class AssetDetailState extends Equatable {
  final WalletAsset walletAsset;
  late AppDatabase? database;
  final Chain chain;
  late WalletService? walletService;

  AssetDetailState.init(this.walletAsset, this.chain);
  AssetDetailState.copy(AssetDetailState state)
      : database = state.database,
        chain = state.chain,
        walletService = state.walletService,
        walletAsset = state.walletAsset;

  @override
  List<Object?> get props => [walletAsset];
}

// ignore: must_be_immutable
class AssetDetailInitialState extends AssetDetailState {
  AssetDetailInitialState(WalletAsset walletAsset, Chain chain)
      : super.init(walletAsset, chain);
}

// ignore: must_be_immutable
class AssetDetailLoadingState extends AssetDetailState {
  AssetDetailLoadingState(AssetDetailState state) : super.copy(state);
}

// ignore: must_be_immutable
class AssetDetailErrorState extends AssetDetailState {
  AssetDetailErrorState(AssetDetailState state) : super.copy(state);
}

// ignore: must_be_immutable
class AssetDetailLoadedState extends AssetDetailState {
  AssetDetailLoadedState(AssetDetailState state) : super.copy(state);
}
