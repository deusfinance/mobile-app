
import 'package:deus_mobile/screens/wallet/cubit/wallet_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitialState());

  init() async {
    // state.database = await FloorAppDatabase.databaseBuilder('deus_database.db').build();
  }

  loadAssets() async {
    final walletAssetDao = state.database.walletAssetDao;
    final walletAssets = await walletAssetDao.getAll();
  }

}