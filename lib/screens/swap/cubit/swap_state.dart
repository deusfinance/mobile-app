import 'dart:async';

import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/deus_swap_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../locator.dart';

abstract class SwapState extends Equatable {
  late SwapService swapService;

  late CryptoCurrency fromToken;
  late CryptoCurrency toToken;
  late double slippage;

  var fromFieldController;
  var toFieldController;
  late double toValue;
  var slippageController;
  late StreamController<String> streamController;

  late bool isPriceRatioForward;
  late bool isInProgress;

  late bool approved;

  SwapState();

  SwapState.init() {
    fromToken = CurrencyData.eth;
    toToken = CurrencyData.deus;
    approved = true;
    slippage = 0.5;
    toValue = 0;
    swapService = new SwapService(
        ethService: new EthereumService(1),
        privateKey: locator<ConfigurationService>().getPrivateKey()!);
    swapService.init();
    fromFieldController = new TextEditingController();
    toFieldController = new TextEditingController();
    slippageController = new TextEditingController();
    streamController = StreamController();

    this.isPriceRatioForward = true;
    this.isInProgress = false;
  }

  SwapState.copy(SwapState swapState)
      : this.swapService = swapState.swapService,
        this.slippage = swapState.slippage,
        this.fromToken = swapState.fromToken,
        this.toToken = swapState.toToken,
        this.toValue = swapState.toValue,
        this.fromFieldController = swapState.fromFieldController,
        this.toFieldController = swapState.toFieldController,
        this.slippageController = swapState.slippageController,
        this.streamController = swapState.streamController,
        this.isPriceRatioForward = swapState.isPriceRatioForward,
        this.approved = swapState.approved,
        this.isInProgress = swapState.isInProgress;

  @override
  List<Object> get props => [fromToken, toToken, slippage, isInProgress, isPriceRatioForward, approved];
}

class SwapLoaded extends SwapState {
  SwapLoaded(SwapState state,
      {fromToken,
        toToken,
        slippage,
        approved,
      SwapService? swapService,
      StreamController<String>? streamController,
      bool? isPriceRatioForward,
      fromFieldController,
      slippageController,
      toFieldController,
      isInProgress,
      showingToast})
      : super.copy(state) {
    if (fromToken != null) this.fromToken = fromToken;
    if (approved != null) this.approved = approved;
    if (toToken != null) this.toToken = toToken;
    if (slippage != null) this.slippage = slippage;
    if (swapService != null) this.swapService = swapService;
    if (streamController != null) this.streamController = streamController;
    if (isPriceRatioForward != null)
      this.isPriceRatioForward = isPriceRatioForward;
    if (slippageController != null)
      this.slippageController = slippageController;
    if (fromFieldController != null)
      this.fromFieldController = fromFieldController;
    if (toFieldController != null) this.toFieldController = toFieldController;
    if (isInProgress != null) this.isInProgress = isInProgress;
  }
}

class TransactionFinishedState extends SwapState {
  bool? _showingToast;
  TransactionStatus? _transactionStatus;

  TransactionFinishedState(SwapState state, {TransactionStatus? transactionStatus, showingToast})
      : super.copy(state) {
    if (transactionStatus != null) {
      this.transactionStatus = transactionStatus;
      this.showingToast = true;
    } else {
      this.showingToast = false;
    }
    if(showingToast!=null) this.showingToast = showingToast;
    this.isInProgress = false;
  }
  @override
  List<Object> get props => [showingToast, transactionStatus];

  TransactionStatus get transactionStatus => _transactionStatus??new TransactionStatus("message", Status.PENDING, "label");

  set transactionStatus(TransactionStatus value) {
    _transactionStatus = value;
  }

  bool get showingToast => _showingToast??false;

  set showingToast(bool value) {
    _showingToast = value;
  }
}

class TransactionPendingState extends SwapState {
  bool? _showingToast;
  TransactionStatus? _transactionStatus;

  TransactionPendingState(SwapState state, {TransactionStatus? transactionStatus, showingToast})
      : super.copy(state) {
    if (transactionStatus != null) {
      this.transactionStatus = transactionStatus;
      this.showingToast = true;
    } else {
      this.showingToast = false;
    }
    if(showingToast!=null) this.showingToast = showingToast;
    this.isInProgress = true;
  }
  @override
  List<Object> get props => [showingToast, transactionStatus];

  TransactionStatus get transactionStatus => _transactionStatus??new TransactionStatus("message", Status.PENDING, "label");

  set transactionStatus(TransactionStatus value) {
    _transactionStatus = value;
  }

  bool get showingToast => _showingToast??false;

  set showingToast(bool value) {
    _showingToast = value;
  }
}

class SwapInitial extends SwapState {
  SwapInitial() : super.init();
}

class SwapLoading extends SwapState {
  SwapLoading(SwapState state) : super.copy(state);
}

class SwapError extends SwapState {
  SwapError(SwapState state) : super.copy(state);
}
