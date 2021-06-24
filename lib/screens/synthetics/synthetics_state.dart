import 'dart:async';

import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/data_source/sync_data/bsc_stock_data.dart';
import 'package:deus_mobile/data_source/sync_data/heco_stock_data.dart';
import 'package:deus_mobile/data_source/sync_data/matic_stock_data.dart';
import 'package:deus_mobile/data_source/sync_data/stock_data.dart';
import 'package:deus_mobile/data_source/sync_data/sync_data.dart';
import 'package:deus_mobile/data_source/sync_data/xdai_stock_data.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/synthetics/stock_price.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/service/sync/bsc_stock_service.dart';
import 'package:deus_mobile/service/sync/heco_stock_service.dart';
import 'package:deus_mobile/service/sync/matic_stock_service.dart';
import 'package:deus_mobile/service/sync/stock_service.dart';
import 'package:deus_mobile/service/sync/sync_service.dart';
import 'package:deus_mobile/service/sync/xdai_stock_service.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

enum Mode { LONG, SHORT, NONE }
enum SyntheticsChain { ETH, XDAI, MATIC, HECO, BSC }

abstract class SyntheticsState extends Equatable {
  late Token fromToken;
  late Token mainToken;
  Token? toToken;
  double toValue;
  bool approved;
  bool isInProgress;
  bool isPriceRatioForward;
  var fromFieldController;
  var toFieldController;
  late SyncService service;
  Mode mode;
  bool marketClosed;
  bool marketTimerClosed;
  StreamController<String> inputController;
  Map<String, StockPrice> prices;
  late SyncData syncData;

  SyntheticsChain syntheticsChain;
  Timer? timer;

  SyntheticsState.copy(SyntheticsState state)
      : this.fromToken = state.fromToken,
        this.isInProgress = state.isInProgress,
        this.toToken = state.toToken,
        this.approved = state.approved,
        this.syntheticsChain = state.syntheticsChain,
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
        this.mainToken = state.mainToken,
        this.syncData = state.syncData,
        this.toFieldController = state.toFieldController;

  SyntheticsState.init(SyntheticsChain syntheticsChain)
      : isInProgress = false,
        approved = true,
        toValue = 0,
        marketClosed = false,
        marketTimerClosed = false,
        fromFieldController = new TextEditingController(),
        toFieldController = new TextEditingController(),
        isPriceRatioForward = true,
        prices = new Map(),
        inputController = StreamController(),
        mode = Mode.NONE,
        this.syntheticsChain = syntheticsChain {
    switch (this.syntheticsChain) {
      case SyntheticsChain.ETH:
        mainToken = CurrencyData.dai;
        fromToken = CurrencyData.dai;
        service = new StockService(
            ethService: new EthereumService(1),
            privateKey: locator<ConfigurationService>().getPrivateKey()!);
        syncData = new StockData();
        break;
      case SyntheticsChain.XDAI:
        fromToken = CurrencyData.xdai;
        mainToken = CurrencyData.xdai;
        service = new XDaiStockService(
            ethService: new EthereumService(100),
            privateKey: locator<ConfigurationService>().getPrivateKey()!);
        syncData = new XDaiStockData();
        Statics.xDaiStockData = syncData as XDaiStockData;
        break;
      case SyntheticsChain.MATIC:
        fromToken = CurrencyData.usdc;
        mainToken = CurrencyData.usdc;
        service = new MaticStockService(
            ethService: new EthereumService(137),
            privateKey: locator<ConfigurationService>().getPrivateKey()!);
        syncData = new MaticStockData();
        break;
      case SyntheticsChain.HECO:
        fromToken = CurrencyData.husd;
        mainToken = CurrencyData.husd;
        service = new HecoStockService(
            ethService: new EthereumService(128),
            privateKey: locator<ConfigurationService>().getPrivateKey()!);
        syncData = new HecoStockData();
        break;
      case SyntheticsChain.BSC:
        fromToken = CurrencyData.busd;
        mainToken = CurrencyData.busd;
        service = new BscStockService(
            ethService: new EthereumService(56),
            privateKey: locator<ConfigurationService>().getPrivateKey()!);
        syncData = new BscStockData();
        break;
      default:
        fromToken = CurrencyData.xdai;
        mainToken = CurrencyData.xdai;
        service = new StockService(
            ethService: new EthereumService(1),
            privateKey: locator<ConfigurationService>().getPrivateKey()!);
        syncData = new StockData();
    }
  }

  @override
  List<Object?> get props => [
        fromToken,
        toToken,
        approved,
        isInProgress,
        mode,
        isPriceRatioForward,
        service,
        prices,
        timer,
        toValue,
        marketClosed,
        marketTimerClosed
      ];
}

class SyntheticsInitialState extends SyntheticsState {
  SyntheticsInitialState(SyntheticsChain chain) : super.init(chain);
}

class SyntheticsLoadingState extends SyntheticsState {
  SyntheticsLoadingState(SyntheticsState state) : super.copy(state);
}

class SyntheticsErrorState extends SyntheticsState {
  SyntheticsErrorState(SyntheticsState state) : super.copy(state);
}

class SyntheticsSelectAssetState extends SyntheticsState {
  SyntheticsSelectAssetState(SyntheticsState state) : super.copy(state);
}

class SyntheticsAssetSelectedState extends SyntheticsState {
  SyntheticsAssetSelectedState(SyntheticsState state,
      {bool? isInProgress,
      bool? approved,
      Token? fromToken,
      Token? toToken,
      bool? isPriceRatioForward,
      Mode? mode})
      : super.copy(state) {
    if (isInProgress != null) this.isInProgress = isInProgress;
    if (approved != null) this.approved = approved;
    if (mode != null) this.mode = mode;
    if (isPriceRatioForward != null)
      this.isPriceRatioForward = isPriceRatioForward;
  }
}

class SyntheticsTransactionPendingState extends SyntheticsState {
  bool? _showingToast;
  TransactionStatus? _transactionStatus;

  SyntheticsTransactionPendingState(SyntheticsState state,
      {TransactionStatus? transactionStatus, showingToast})
      : super.copy(state) {
    if (transactionStatus != null) {
      this._transactionStatus = transactionStatus;
      this._showingToast = true;
    } else {
      this._showingToast = false;
    }
    if (showingToast != null) this._showingToast = showingToast;
    this.isInProgress = true;
  }

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

  @override
  List<Object?> get props => [showingToast, transactionStatus];
}

class SyntheticsTransactionFinishedState extends SyntheticsState {
  bool? _showingToast;
  TransactionStatus? _transactionStatus;

  SyntheticsTransactionFinishedState(SyntheticsState state,
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

  @override
  List<Object?> get props => [showingToast, transactionStatus];
}
