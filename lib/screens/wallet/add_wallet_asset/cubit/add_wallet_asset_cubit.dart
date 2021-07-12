import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'package:deus_mobile/models/token.dart';
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
    state.database = await AppDatabase.getInstance();
    state.walletAssetApis = await getWalletAssets();
    state.streamController.stream
        .debounce(Duration(milliseconds: 300))
        .listen((s) async {
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

    if(!state.tokenAddressController.hasListeners)
      state.tokenAddressController.addListener(() {
        String text = state.tokenAddressController.text.toString();
        if(text.startsWith("0x") && text.length == 42){
          state.addressConfirmed = true;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }else{
          state.addressConfirmed = false;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }
      });

    if(!state.tokenSymbolController.hasListeners)
      state.tokenSymbolController.addListener(() {
        String text = state.tokenSymbolController.text.toString();
        if(text.length <= 11){
          state.symbolConfirmed = true;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }else{
          state.symbolConfirmed = false;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }
      });

    if(!state.tokenDecimalController.hasListeners)
      state.tokenDecimalController.addListener(() {
        String text = state.tokenDecimalController.text.toString();
        if(int.tryParse(text) != null){
          state.decimalConfirmed = true;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }else{
          state.decimalConfirmed = false;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }
      });

    emit(AddWalletAssetSearchState(state));
  }

  visibleErrors(bool b){
    state.visibleErrors = b;
    emit(AddWalletAssetLoadingState(state));
    emit(AddWalletAssetCustomState(state));
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
