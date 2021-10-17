import '../../../core/database/chain.dart';
import '../../../core/database/database.dart';
import '../../../core/database/wallet_asset.dart';
import '../../../locator.dart';
import '../../../service/config_service.dart';
import '../../../service/wallet_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'asset_detail_state.dart';

class AssetDetailCubit extends Cubit<AssetDetailState> {
  AssetDetailCubit(WalletAsset walletAsset, Chain chain)
      : super(AssetDetailInitialState(walletAsset, chain));

  void init() async {
    emit(AssetDetailLoadingState(state));
    state.database = await AppDatabase.getInstance();
    state.walletService = new WalletService(
        state.chain, locator<ConfigurationService>().getPrivateKey()!);
    emit(AssetDetailLoadedState(state));
  }
}
