import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/models/wallet/wallet_asset_api.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'add_wallet_asset_state.dart';

class AddWalletAssetCubit extends Cubit<AddWalletAssetState> {
  AddWalletAssetCubit(Chain chain) : super(AddWalletAssetInitialState(chain));

  init() async {
    emit(AddWalletAssetLoadingState(state));
    state.database =
        await $FloorAppDatabase.databaseBuilder(Statics.DB_NAME).build();
    state.walletAssetApis = await getWalletAssets();

    state.streamController.stream
        .debounce(Duration(milliseconds: 300))
        .listen((s) async {
      // emit(AddWalletAssetLoadingState(state));
      search(s).then((value) {
        state.searchedWalletAssetApis = value;
        emit(AddWalletAssetLoadingState(state));
        emit(AddWalletAssetSearchState(state));
      });
    });

    if (!state.tokenSearchController.hasListeners) {
      state.tokenSearchController.addListener(() async {
        String input = state.tokenSearchController.text.toString();
        if(input.isNotEmpty)
          state.streamController.add(input);
      });
    }

    emit(AddWalletAssetSearchState(state));
  }

  Future<List<WalletAssetApi>> search(String pattern) async {
    List<WalletAssetApi> data = [];
    if (pattern.length == 0)
      return data;
    if (state.walletAssetApis != null) {
      data = await Future.sync(() {
        return state.walletAssetApis!
            .where((element) =>
                (element.symbol).toLowerCase().contains(pattern) ||
                (element.address).toLowerCase().contains(pattern))
            .toList();
      });
    }
    return data;
  }

  Future<List<WalletAssetApi>> getWalletAssets() async {
    var response = await http.get(
        Uri.parse("https://apiv4.paraswap.io/v2/tokens/${state.chain.id}"));
    if (response.statusCode == 200) {
      LinkedHashMap<String, dynamic> map = json.decode(response.body);
      List<dynamic> list = map['tokens'];
      List<WalletAssetApi> walletAssetApis = [];
      list.forEach((item) {
        WalletAssetApi p = new WalletAssetApi.fromJson(item);
        walletAssetApis.add(p);
      });
      return walletAssetApis;
    } else {
      return List.empty();
    }
  }

  void changeTab(int i) {
    if (i == 0)
      emit(AddWalletAssetSearchState(state));
    else
      emit(AddWalletAssetCustomState(state));
  }
}
