import 'dart:async';

import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/models/synthetics/stock_price.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_state.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/service/stock_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../locator.dart';

abstract class MainnetSyntheticsState extends Equatable {
  Token fromToken;
  Token toToken;
  double toValue;
  bool approved;
  bool isInProgress;
  bool isPriceRatioForward;
  var fromFieldController;
  var toFieldController;
  StockService service;
  Mode mode;
  bool marketClosed;
  bool marketTimerClosed;
  StreamController<String> inputController;

  Map<String, StockPrice> prices;
  Timer timer;

  MainnetSyntheticsState();

  MainnetSyntheticsState.init()
      : isInProgress = false,
        fromToken = CurrencyData.dai,
        approved = true,
        toValue = 0,
        marketClosed = false,
        marketTimerClosed = false,
        fromFieldController = new TextEditingController(),
        toFieldController = new TextEditingController(),
        isPriceRatioForward = true,
        prices = new Map(),
        inputController = StreamController(),
        service = new StockService(
            ethService: new EthereumService(1),
            privateKey: locator<ConfigurationService>().getPrivateKey());

  MainnetSyntheticsState.copy(MainnetSyntheticsState state)
      : this.fromToken = state.fromToken,
        this.toToken = state.toToken,
        this.isInProgress = state.isInProgress,
        this.approved = state.approved,
        this.service = state.service,
        this.prices = state.prices,
        this.marketClosed = state.marketClosed,
        this.marketTimerClosed = state.marketTimerClosed,
        this.timer = state.timer,
        this.toValue = state.toValue,
        this.isPriceRatioForward = state.isPriceRatioForward,
        this.inputController = state.inputController,
        this.fromFieldController = state.fromFieldController,
        this.mode = state.mode,
        this.toFieldController = state.toFieldController;

  @override
  List<Object> get props => [fromToken, toToken, approved, isInProgress, mode, isPriceRatioForward, service, prices, timer, toValue, marketClosed, marketTimerClosed];
}

class MainnetSyntheticsInitialState extends MainnetSyntheticsState {
  MainnetSyntheticsInitialState() : super.init();
}

class MainnetSyntheticsLoadingState extends MainnetSyntheticsState {
  MainnetSyntheticsLoadingState(MainnetSyntheticsState state) : super.copy(state);
}

class MainnetSyntheticsErrorState extends MainnetSyntheticsState {
  MainnetSyntheticsErrorState(MainnetSyntheticsState state) : super.copy(state);
}

class MainnetSyntheticsSelectAssetState extends MainnetSyntheticsState {
  MainnetSyntheticsSelectAssetState(MainnetSyntheticsState state) : super.copy(state);
}

class MainnetSyntheticsAssetSelectedState extends MainnetSyntheticsState {
  MainnetSyntheticsAssetSelectedState(MainnetSyntheticsState state,
      {bool isInProgress,
      bool approved,
      Token fromToken,
      Token toToken,
      bool isPriceRatioForward,
      Mode mode})
      : super.copy(state) {
    if (isInProgress != null) this.isInProgress = isInProgress;
    if (approved != null) this.approved = approved;
    if (mode != null) this.mode = mode;
    if (isPriceRatioForward != null)
      this.isPriceRatioForward = isPriceRatioForward;
  }
}

class MainnetSyntheticsTransactionPendingState extends MainnetSyntheticsState {
  bool showingToast;
  TransactionStatus transactionStatus;

  MainnetSyntheticsTransactionPendingState(MainnetSyntheticsState state,
      {TransactionStatus transactionStatus, showingToast})
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
}

class MainnetSyntheticsTransactionFinishedState extends MainnetSyntheticsState {
  bool showingToast;
  TransactionStatus transactionStatus;

  MainnetSyntheticsTransactionFinishedState(MainnetSyntheticsState state,
      {TransactionStatus transactionStatus, showingToast})
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
}
