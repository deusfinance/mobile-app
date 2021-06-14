import 'dart:async';

import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/models/synthetics/stock_price.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_state.dart';
import 'package:deus_mobile/service/bsc_stock_service.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/service/stock_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../locator.dart';

abstract class BscSyntheticsState extends Equatable {
  Token fromToken;
  Token toToken;
  double toValue;
  bool approved;
  bool isInProgress;
  bool isPriceRatioForward;
  var fromFieldController;
  var toFieldController;
  BscStockService service;
  Mode mode;
  bool marketClosed;
  bool marketTimerClosed;
  StreamController<String> inputController;

  Map<String, StockPrice> prices;
  Timer timer;

  BscSyntheticsState();

  BscSyntheticsState.init()
      : isInProgress = false,
        fromToken = CurrencyData.bsc,
        approved = true,
        toValue = 0,
        marketClosed = false,
        marketTimerClosed = false,
        fromFieldController = new TextEditingController(),
        toFieldController = new TextEditingController(),
        isPriceRatioForward = true,
        prices = new Map(),
        inputController = StreamController(),
        service = new BscStockService(
            ethService: new EthereumService(97),
            privateKey: locator<ConfigurationService>().getPrivateKey());

  BscSyntheticsState.copy(BscSyntheticsState state)
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

class BscSyntheticsInitialState extends BscSyntheticsState {
  BscSyntheticsInitialState() : super.init();
}

class BscSyntheticsLoadingState extends BscSyntheticsState {
  BscSyntheticsLoadingState(BscSyntheticsState state) : super.copy(state);
}

class BscSyntheticsErrorState extends BscSyntheticsState {
  BscSyntheticsErrorState(BscSyntheticsState state) : super.copy(state);
}

class BscSyntheticsSelectAssetState extends BscSyntheticsState {
  BscSyntheticsSelectAssetState(BscSyntheticsState state) : super.copy(state);
}

class BscSyntheticsAssetSelectedState extends BscSyntheticsState {
  BscSyntheticsAssetSelectedState(BscSyntheticsState state,
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

class BscSyntheticsTransactionPendingState extends BscSyntheticsState {
  bool showingToast;
  TransactionStatus transactionStatus;

  BscSyntheticsTransactionPendingState(BscSyntheticsState state,
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

class BscSyntheticsTransactionFinishedState extends BscSyntheticsState {
  bool showingToast;
  TransactionStatus transactionStatus;

  BscSyntheticsTransactionFinishedState(BscSyntheticsState state,
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
