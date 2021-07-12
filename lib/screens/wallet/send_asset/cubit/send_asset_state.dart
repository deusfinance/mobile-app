import 'dart:async';

import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/service/wallet_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SendAssetState extends Equatable {
  late TextEditingController amountController;
  late TextEditingController recAddressController;
  late StreamController<String> streamController;
  bool addressConfirmed;

  WalletAsset walletAsset;
  WalletService walletService;
  AppDatabase? database;

  late bool isInProgress;

  SendAssetState.init(this.walletAsset, this.walletService):
  addressConfirmed = false{
    amountController = new TextEditingController();
    recAddressController = new TextEditingController();
    streamController = StreamController();
    this.isInProgress = false;
  }

  SendAssetState.copy(SendAssetState state)
      : this.amountController = state.amountController,
        this.database = state.database,
        this.recAddressController = state.recAddressController,
        this.streamController = state.streamController,
        this.walletAsset = state.walletAsset,
        this.addressConfirmed = state.addressConfirmed,
        this.walletService = state.walletService,
        this.isInProgress = state.isInProgress;

  @override
  List<Object> get props => [isInProgress];
}

class SendAssetLoadedState extends SendAssetState {
  SendAssetLoadedState(SendAssetState state) : super.copy(state);
}

class TransactionFinishedState extends SendAssetState {
  bool? _showingToast;
  TransactionStatus? _transactionStatus;

  TransactionFinishedState(SendAssetState state,
      {TransactionStatus? transactionStatus, showingToast})
      : super.copy(state) {
    if (transactionStatus != null) {
      this.transactionStatus = transactionStatus;
      this.showingToast = true;
    } else {
      this.showingToast = false;
    }
    if (showingToast != null) this.showingToast = showingToast;
    this.isInProgress = false;
  }

  @override
  List<Object> get props => [showingToast, transactionStatus];

  TransactionStatus get transactionStatus =>
      _transactionStatus ??
      new TransactionStatus("message", Status.PENDING, "label");

  set transactionStatus(TransactionStatus value) {
    _transactionStatus = value;
  }

  bool get showingToast => _showingToast ?? false;

  set showingToast(bool value) {
    _showingToast = value;
  }
}

class TransactionPendingState extends SendAssetState {
  bool? _showingToast;
  TransactionStatus? _transactionStatus;

  TransactionPendingState(SendAssetState state,
      {TransactionStatus? transactionStatus, showingToast})
      : super.copy(state) {
    if (transactionStatus != null) {
      this.transactionStatus = transactionStatus;
      this.showingToast = true;
    } else {
      this.showingToast = false;
    }
    if (showingToast != null) this.showingToast = showingToast;
    this.isInProgress = true;
  }

  @override
  List<Object> get props => [showingToast, transactionStatus];

  TransactionStatus get transactionStatus =>
      _transactionStatus ??
      new TransactionStatus("message", Status.PENDING, "label");

  set transactionStatus(TransactionStatus value) {
    _transactionStatus = value;
  }

  bool get showingToast => _showingToast ?? false;

  set showingToast(bool value) {
    _showingToast = value;
  }
}

class SendAssetInitialState extends SendAssetState {
  SendAssetInitialState(WalletAsset walletAsset, WalletService walletService)
      : super.init(walletAsset, walletService);
}

class SendAssetLoadingState extends SendAssetState {
  SendAssetLoadingState(SendAssetState state) : super.copy(state);
}

class SendAssetErrorState extends SendAssetState {
  SendAssetErrorState(SendAssetState state) : super.copy(state);
}
