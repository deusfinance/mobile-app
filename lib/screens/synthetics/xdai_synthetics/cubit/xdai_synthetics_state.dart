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

enum Mode { LONG, SHORT }

abstract class XDaiSyntheticsState extends Equatable {
  Token from;
  Token to;
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
        from = CurrencyData.xdai,
        approved = true,
        fromFieldController = new TextEditingController(),
        toFieldController = new TextEditingController(),
        isPriceRatioForward = true,
        streamController = StreamController(),
        service = new XDaiStockService(
            ethService: new EthereumService(100),
            privateKey: locator<ConfigurationService>().getPrivateKey());

  XDaiSyntheticsState.copy(XDaiSyntheticsState state)
      : this.from = state.from,
        this.to = state.to,
        this.isInProgress = state.isInProgress,
        this.approved = state.approved,
        this.service = state.service,
        this.isPriceRatioForward = state.isPriceRatioForward,
        this.streamController = state.streamController,
        this.fromFieldController = state.fromFieldController,
        this.mode = state.mode,
        this.toFieldController = state.toFieldController;

  @override
  List<Object> get props => [from, to, approved, isInProgress, mode];
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
  XDaiSyntheticsErrorState() : super();
}

class XDaiSyntheticsSelectAssetState extends XDaiSyntheticsState {
  XDaiSyntheticsSelectAssetState(XDaiSyntheticsState state) : super.copy(state);
}

class XDaiSyntheticsAssetSelectedState extends XDaiSyntheticsState {
  XDaiSyntheticsAssetSelectedState(XDaiSyntheticsState state,
      {bool isInProgress, bool approved})
      : super.copy(state) {
    if (isInProgress != null) this.isInProgress = isInProgress;
    if (approved != null) this.approved = approved;
  }
}

class XDaiSyntheticsTransactionPendingState extends XDaiSyntheticsState {
  bool showingToast;
  TransactionStatus transactionStatus;

  XDaiSyntheticsTransactionPendingState() : super();
}

class XDaiSyntheticsTransactionFinishedState extends XDaiSyntheticsState {
  bool showingToast;
  TransactionStatus transactionStatus;

  XDaiSyntheticsTransactionFinishedState() : super();
}
