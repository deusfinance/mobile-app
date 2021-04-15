part of 'stake_cubit.dart';

abstract class StakeState extends Equatable {
  bool showToast;
  StakeService stakeService;
  StakeTokenObject stakeTokenObject;
  double balance;
  var fieldController;
  bool isInProgress;
  bool approved;

  StakeState.init(StakeTokenObject object) {
    stakeService = new StakeService(
        ethService: new EthereumService(1),
        privateKey: locator<ConfigurationService>().getPrivateKey());
    stakeTokenObject = object;
    balance = 0;
    showToast = false;
    approved = false;
    fieldController = new TextEditingController();
    isInProgress = false;
  }

  StakeState.copy(StakeState state) {
    this.stakeTokenObject = state.stakeTokenObject;
    this.stakeService = state.stakeService;
    this.balance = state.balance;
    this.showToast = state.showToast;
    this.fieldController = state.fieldController;
    this.isInProgress = state.isInProgress;
    this.approved = state.approved;
  }
  @override
  List<Object> get props =>
      [showToast, stakeService, stakeTokenObject, balance, isInProgress, fieldController, approved];
}

class StakeLoading extends StakeState {
  StakeLoading(StakeState state) : super.copy(state);
}

class StakeInit extends StakeState {
  StakeInit(StakeTokenObject object) : super.init(object);
}

class StakeHasToApprove extends StakeState {
  StakeHasToApprove(StakeState state, {bool showToast, bool isInProgress}) : super.copy(state) {
    approved = false;
    if(showToast!= null)
      this.showToast = showToast;
    if(isInProgress!= null)
      this.isInProgress = isInProgress;
  }
}

// class StakePendingApproveDividedButton extends StakeState {
//   StakePendingApproveDividedButton(StakeState state, {bool showToast}) : super.copy(state){
//     if(showToast!= null)
//       this.showToast = showToast;
//   }
// }

class StakeIsApproved extends StakeState {
  StakeIsApproved(StakeState state, {bool showToast, bool isInProgress}) : super.copy(state){
    approved = true;
    if(showToast!= null)
      this.showToast = showToast;
    if(isInProgress!= null)
      this.isInProgress = isInProgress;
  }
}

// class StakePendingApproveMergedButton extends StakeState {
//   StakePendingApproveMergedButton(StakeState state, {bool showToast}) : super.copy(state){
//     if(showToast!= null)
//       this.showToast = showToast;
//   }
// }

class StakeTransactionPendingState extends StakeState {
  bool showingToast;
  TransactionStatus transactionStatus;

  StakeTransactionPendingState(StakeState state,
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

class StakeTransactionFinishedState extends StakeState {
  bool showingToast;
  TransactionStatus transactionStatus;

  StakeTransactionFinishedState(StakeState state,
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
