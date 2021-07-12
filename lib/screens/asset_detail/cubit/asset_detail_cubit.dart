import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/wallet/wallet_asset_api.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/wallet_service.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'asset_detail_state.dart';

class AssetDetailCubit extends Cubit<AssetDetailState> {
  AssetDetailCubit(WalletAsset walletAsset, Chain chain) : super(AssetDetailInitialState(walletAsset, chain));

  init() async {
    emit(AssetDetailLoadingState(state));
    state.database = await AppDatabase.getInstance();
    state.walletService = new WalletService(state.chain, locator<ConfigurationService>().getPrivateKey()!);
    emit(AssetDetailLoadedState(state));
  }
}
