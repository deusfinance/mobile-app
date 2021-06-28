import 'dart:async';

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/models/wallet/wallet_asset_api.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class AddWalletAssetState extends Equatable {
  AppDatabase? database;
  Chain chain;
  List<WalletAssetApi>? walletAssetApis;
  List<WalletAssetApi>? searchedWalletAssetApis;
  StreamController streamController;

  var tokenSearchController;
  var tokenDecimalController;
  var tokenSymbolController;
  var tokenAddressController;

  AddWalletAssetState.init(this.chain):
        streamController = new StreamController()
  {
    walletAssetApis = new List.empty();
    searchedWalletAssetApis = new List.empty();
    tokenSearchController = new TextEditingController();
    tokenDecimalController = new TextEditingController();
    tokenSymbolController = new TextEditingController();
    tokenAddressController = new TextEditingController();
  }

  AddWalletAssetState.copy(AddWalletAssetState state)
      : database = state.database,
        streamController = state.streamController,
        chain = state.chain,
        walletAssetApis = state.walletAssetApis,
        searchedWalletAssetApis = state.searchedWalletAssetApis,
        tokenAddressController = state.tokenAddressController,
        tokenSymbolController = state.tokenSymbolController,
        tokenDecimalController = state.tokenDecimalController,
        tokenSearchController = state.tokenSearchController;

  @override
  List<Object?> get props => [chain];
}

class AddWalletAssetInitialState extends AddWalletAssetState {
  AddWalletAssetInitialState(Chain chain) : super.init(chain);
}

class AddWalletAssetLoadingState extends AddWalletAssetState {
  AddWalletAssetLoadingState(AddWalletAssetState state) : super.copy(state);
}

class AddWalletAssetErrorState extends AddWalletAssetState {
  AddWalletAssetErrorState(AddWalletAssetState state) : super.copy(state);
}

class AddWalletAssetSearchState extends AddWalletAssetState {
  AddWalletAssetSearchState(AddWalletAssetState state) : super.copy(state);
}

class AddWalletAssetCustomState extends AddWalletAssetState {
  AddWalletAssetCustomState(AddWalletAssetState state) : super.copy(state);
}
