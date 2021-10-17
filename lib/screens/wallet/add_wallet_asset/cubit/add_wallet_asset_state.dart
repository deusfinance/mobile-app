import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/database/chain.dart';
import '../../../../core/database/database.dart';
import '../../../../models/wallet/wallet_asset_api.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
abstract class AddWalletAssetState extends Equatable {
  AppDatabase? database;
  Chain chain;
  List<WalletAssetApi>? walletAssetApis;
  List<WalletAssetApi>? searchedWalletAssetApis;
  StreamController streamController;
  bool addressConfirmed;
  bool decimalConfirmed;
  bool symbolConfirmed;
  bool visibleErrors;

  late TextEditingController tokenSearchController;
  late TextEditingController tokenDecimalController;
  late TextEditingController tokenSymbolController;
  late TextEditingController tokenAddressController;

  AddWalletAssetState.init(this.chain)
      : addressConfirmed = false,
        visibleErrors = false,
        decimalConfirmed = false,
        symbolConfirmed = false,
        streamController = new StreamController() {
    walletAssetApis = new List.empty();
    searchedWalletAssetApis = new List.empty();
    tokenSearchController = new TextEditingController();
    tokenDecimalController = new TextEditingController();
    tokenSymbolController = new TextEditingController();
    tokenAddressController = new TextEditingController();
  }

  AddWalletAssetState.copy(AddWalletAssetState state)
      : database = state.database,
        addressConfirmed = state.addressConfirmed,
        visibleErrors = state.visibleErrors,
        symbolConfirmed = state.symbolConfirmed,
        decimalConfirmed = state.decimalConfirmed,
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

// ignore: must_be_immutable
class AddWalletAssetInitialState extends AddWalletAssetState {
  AddWalletAssetInitialState(Chain chain) : super.init(chain);
}

// ignore: must_be_immutable
class AddWalletAssetLoadingState extends AddWalletAssetState {
  AddWalletAssetLoadingState(AddWalletAssetState state) : super.copy(state);
}

// ignore: must_be_immutable
class AddWalletAssetErrorState extends AddWalletAssetState {
  AddWalletAssetErrorState(AddWalletAssetState state) : super.copy(state);
}

// ignore: must_be_immutable
class AddWalletAssetSearchState extends AddWalletAssetState {
  AddWalletAssetSearchState(AddWalletAssetState state) : super.copy(state);
}

// ignore: must_be_immutable
class AddWalletAssetCustomState extends AddWalletAssetState {
  AddWalletAssetCustomState(AddWalletAssetState state) : super.copy(state);
}
