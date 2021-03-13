import 'dart:async';

import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/service/xdai_stock_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../locator.dart';

enum Mode {LONG, SHORT}
abstract class XDaiSyntheticsState extends Equatable {
  Token fromToken;
  Token toToken;
  bool approved;
  bool isInProgress;
  bool isPriceRatioForward;
  var fromFieldController;
  var toFieldController;
  XDaiStockService service;
  Mode mode;
  StreamController<String> streamController;

  XDaiSyntheticsState();

  XDaiSyntheticsState.init()
      : isInProgress = false,
        fromToken = CurrencyData.xdai,
        approved = true,
        fromFieldController = new TextEditingController(),
        toFieldController = new TextEditingController(),
        isPriceRatioForward = true,
        streamController = StreamController(),
        service = new XDaiStockService(
            ethService: new EthereumService(100),
            privateKey: locator<ConfigurationService>().getPrivateKey());

  XDaiSyntheticsState.copy(XDaiSyntheticsState state)
      : this.fromToken = state.fromToken,
        this.toToken = state.toToken,
        this.isInProgress = state.isInProgress,
        this.approved = state.approved,
        this.service = state.service,
        this.isPriceRatioForward = state.isPriceRatioForward,
        this.streamController = state.streamController,
        this.fromFieldController = state.fromFieldController,
        this.mode = state.mode,
        this.toFieldController = state.toFieldController;

  @override
  List<Object> get props => [fromToken, toToken, approved, isInProgress, mode];
}

class XDaiSyntheticsInitialState extends XDaiSyntheticsState {
  XDaiSyntheticsInitialState() : super.init();
}

class XDaiSyntheticsLoadingState extends XDaiSyntheticsState {
  XDaiSyntheticsLoadingState(XDaiSyntheticsState state) : super.copy(state);
}

class XDaiSyntheticsMarketClosedState extends XDaiSyntheticsState {
  XDaiSyntheticsMarketClosedState() : super();
}

class XDaiSyntheticsErrorState extends XDaiSyntheticsState {
  XDaiSyntheticsErrorState(XDaiSyntheticsState state) : super.copy(state);
}

class XDaiSyntheticsSelectAssetState extends XDaiSyntheticsState {
  XDaiSyntheticsSelectAssetState(XDaiSyntheticsState state) : super.copy(state);
}

class XDaiSyntheticsAssetSelectedState extends XDaiSyntheticsState {
  XDaiSyntheticsAssetSelectedState(XDaiSyntheticsState state,
      {bool isInProgress, bool approved, Token fromToken, Token toToken, bool isPriceRatioForward, Mode mode})
      : super.copy(state) {
    if (isInProgress != null) this.isInProgress = isInProgress;
    if (approved != null) this.approved = approved;
    if (mode != null) this.mode = mode;
    if (isPriceRatioForward != null) this.isPriceRatioForward = isPriceRatioForward;
  }
}

class XDaiSyntheticsTransactionPendingState extends XDaiSyntheticsState {
  bool showingToast;
  TransactionStatus transactionStatus;

  XDaiSyntheticsTransactionPendingState(XDaiSyntheticsState state, {TransactionStatus transactionStatus, showingToast}) : super.copy(state){
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
}

class XDaiSyntheticsTransactionFinishedState extends XDaiSyntheticsState {
  bool showingToast;
  TransactionStatus transactionStatus;

  XDaiSyntheticsTransactionFinishedState(XDaiSyntheticsState state, {TransactionStatus transactionStatus, showingToast}) : super.copy(state){
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
}
