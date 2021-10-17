import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import '../../../../core/database/chain.dart';
import '../../../../core/database/database.dart';
import '../../../../models/wallet/wallet_asset_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'add_wallet_asset_state.dart';

class AddWalletAssetCubit extends Cubit<AddWalletAssetState> {
  AddWalletAssetCubit(Chain chain) : super(AddWalletAssetInitialState(chain));

  Future<void> init() async {
    emit(AddWalletAssetLoadingState(state));
    state.database = await AppDatabase.getInstance();
    state.walletAssetApis = await getWalletAssets();
    state.streamController.stream
        .debounce(const Duration(milliseconds: 300))
        .listen((s) async {
      await search(s).then((value) {
        state.searchedWalletAssetApis = value;
        emit(AddWalletAssetLoadingState(state));
        emit(AddWalletAssetSearchState(state));
      });
    });

    // ignore: invalid_use_of_protected_member
    if (!state.tokenSearchController.hasListeners) {
      state.tokenSearchController.addListener(() async {
        final String input = state.tokenSearchController.text.toString();
        if (input.isNotEmpty) state.streamController.add(input);
      });
    }

    // ignore: invalid_use_of_protected_member
    if (!state.tokenAddressController.hasListeners)
      state.tokenAddressController.addListener(() {
        final String text = state.tokenAddressController.text.toString();
        if (text.startsWith("0x") && text.length == 42) {
          state.addressConfirmed = true;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        } else {
          state.addressConfirmed = false;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }
      });

    // ignore: invalid_use_of_protected_member
    if (!state.tokenSymbolController.hasListeners)
      state.tokenSymbolController.addListener(() {
        final String text = state.tokenSymbolController.text.toString();
        if (text.length <= 11) {
          state.symbolConfirmed = true;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        } else {
          state.symbolConfirmed = false;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }
      });

    // ignore: invalid_use_of_protected_member
    if (!state.tokenDecimalController.hasListeners)
      state.tokenDecimalController.addListener(() {
        final String text = state.tokenDecimalController.text.toString();
        if (int.tryParse(text) != null) {
          state.decimalConfirmed = true;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        } else {
          state.decimalConfirmed = false;
          emit(AddWalletAssetLoadingState(state));
          emit(AddWalletAssetCustomState(state));
        }
      });

    emit(AddWalletAssetSearchState(state));
  }

  void visibleErrors(bool b) {
    state.visibleErrors = b;
    emit(AddWalletAssetLoadingState(state));
    emit(AddWalletAssetCustomState(state));
  }

  Future<List<WalletAssetApi>> search(String pattern) async {
    List<WalletAssetApi> data = [];
    if (pattern.isEmpty) return data;
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
    final response = await http.get(
        Uri.parse("https://apiv4.paraswap.io/v2/tokens/${state.chain.id}"));
    if (response.statusCode == 200) {
      final LinkedHashMap<String, dynamic> map = json.decode(response.body);
      final List<dynamic> list = map['tokens'];
      final List<WalletAssetApi> walletAssetApis = [];
      list.forEach((item) {
        final WalletAssetApi p = new WalletAssetApi.fromJson(item);
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
