part of 'stake_cubit.dart';

abstract class StakeState extends Equatable {
  StakeService stakeService;
  StakeTokenObject stakeTokenObject;
  double balance;
  var fieldController;
  bool showingToast;
  TransactionStatus transactionStatus;

  StakeState.init(StakeTokenObject object) {
    stakeService = new StakeService(
        ethService: new EthereumService(1),
        privateKey: locator<ConfigurationService>().getPrivateKey());
    stakeTokenObject = object;
    balance = 0;
    showingToast = false;
    fieldController = new TextEditingController();
  }

  StakeState.copy(StakeState state) {
    this.stakeTokenObject = state.stakeTokenObject;
    this.stakeService = state.stakeService;
    this.balance = state.balance;
    this.fieldController = state.fieldController;
    this.showingToast = state.showingToast;
    this.transactionStatus = state.transactionStatus;
  }
  @override
  List<Object> get props =>
      [stakeService, stakeTokenObject, balance, fieldController, showingToast, transactionStatus];
}

class StakeLoading extends StakeState {
  StakeLoading(StakeState state) : super.copy(state);
}

class StakeInit extends StakeState {
  StakeInit(StakeTokenObject object) : super.init(object);
}

class StakeHasToApprove extends StakeState {
  StakeHasToApprove(StakeState state, {TransactionStatus transactionStatus, showingToast}) : super.copy(state){
    if (transactionStatus != null) {
      this.transactionStatus = transactionStatus;
      this.showingToast = true;
    } else {
      this.showingToast = false;
    }
    if (showingToast != null)
      this.showingToast = showingToast;
  }
}

class StakePendingApprove extends StakeState {

  StakePendingApprove(StakeState state, {TransactionStatus transactionStatus, showingToast}) : super.copy(state){
    if (transactionStatus != null) {
      this.transactionStatus = transactionStatus;
      this.showingToast = true;
    } else {
      this.showingToast = false;
    }
    if (showingToast != null)
      this.showingToast = showingToast;
  }
}

class StakePendingStake extends StakeState {
  StakePendingStake(StakeState state, {TransactionStatus transactionStatus, showingToast}) : super.copy(state){
    if (transactionStatus != null) {
      this.transactionStatus = transactionStatus;
      this.showingToast = true;
    } else {
      this.showingToast = false;
    }
    if (showingToast != null)
      this.showingToast = showingToast;
  }
}

class StakeIsApproved extends StakeState {
  StakeIsApproved(StakeState state, {TransactionStatus transactionStatus, showingToast}) : super.copy(state){
    if (transactionStatus != null) {
      this.transactionStatus = transactionStatus;
      this.showingToast = true;
    } else {
      this.showingToast = false;
    }
    if (showingToast != null)
      this.showingToast = showingToast;
  }
}



// class StakeTransactionPendingState extends StakeState {
//   bool showingToast;
//   TransactionStatus transactionStatus;
//
//   StakeTransactionPendingState(StakeState state,
//       {TransactionStatus transactionStatus, showingToast})
//       : super.copy(state) {
//     if (transactionStatus != null) {
//       this.transactionStatus = transactionStatus;
//       this.showingToast = true;
//     } else {
//       this.showingToast = false;
//     }
//     if (showingToast != null) this.showingToast = showingToast;
//     this.isInProgress = true;
//   }
//
//   @override
//   List<Object> get props => [showingToast, transactionStatus];
// }
//
// class StakeTransactionFinishedState extends StakeState {
//   bool showingToast;
//   TransactionStatus transactionStatus;
//
//   StakeTransactionFinishedState(StakeState state,
//       {TransactionStatus transactionStatus, showingToast})
//       : super.copy(state) {
//     if (transactionStatus != null) {
//       this.transactionStatus = transactionStatus;
//       this.showingToast = true;
//     } else {
//       this.showingToast = false;
//     }
//     if (showingToast != null) this.showingToast = showingToast;
//     this.isInProgress = false;
//   }
//
//   @override
//   List<Object> get props => [showingToast, transactionStatus];
// }
