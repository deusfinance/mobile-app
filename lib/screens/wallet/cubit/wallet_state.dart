import '../../../core/database/chain.dart';
import '../../../core/database/database.dart';
import '../../../models/transaction_status.dart';
import '../../../service/wallet_service.dart';
import 'package:equatable/equatable.dart';

enum WalletTab { ACTIVITY, ASSETS }

// ignore: must_be_immutable
abstract class WalletState extends Equatable {
  AppDatabase? database;
  Stream<List<Chain>> chains;
  Chain? selectedChain;
  WalletService? walletService;
  bool isInProgress;
  WalletTab walletTab;

  WalletState.init()
      : isInProgress = false,
        walletTab = WalletTab.ASSETS,
        chains = const Stream.empty();

  WalletState.copy(WalletState state)
      : isInProgress = state.isInProgress,
        database = state.database,
        walletTab = state.walletTab,
        walletService = state.walletService,
        selectedChain = state.selectedChain,
        chains = state.chains;

  @override
  List<Object?> get props =>
      [chains, selectedChain, walletService, database, isInProgress];
}

// ignore: must_be_immutable
class WalletInitialState extends WalletState {
  WalletInitialState() : super.init();
}

// ignore: must_be_immutable
class WalletLoadingState extends WalletState {
  WalletLoadingState(WalletState state) : super.copy(state);
}

// ignore: must_be_immutable
class WalletErrorState extends WalletState {
  WalletErrorState(WalletState state) : super.copy(state);
}

// ignore: must_be_immutable
class WalletLoadedState extends WalletState {
  WalletLoadedState(WalletState state) : super.copy(state);
}

// ignore: must_be_immutable
class WalletTransactionPendingState extends WalletState {
  bool? _showingToast;
  TransactionStatus? _transactionStatus;

  WalletTransactionPendingState(WalletState state,
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

// ignore: must_be_immutable
class WalletTransactionFinishedState extends WalletState {
  bool? _showingToast;
  TransactionStatus? _transactionStatus;

  WalletTransactionFinishedState(WalletState state,
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
