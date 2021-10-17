// part of 'lock_cubit.dart';
//
// abstract class LockState extends Equatable {
//   late VaultsService vaultsService;
//   late StakeTokenObject stakeTokenObject;
//   late double balance;
//   var fieldController;
//   late bool showingToast;
//   late TransactionStatus transactionStatus;
//
//   LockState.init(StakeTokenObject object) {
//     vaultsService = new VaultsService(
//         ethService: new EthereumService(1),
//         privateKey: locator<ConfigurationService>().getPrivateKey()!);
//     stakeTokenObject = object;
//     balance = 0;
//     showingToast = false;
//     fieldController = new TextEditingController();
//   }
//
//   LockState.copy(LockState state) {
//     this.stakeTokenObject = state.stakeTokenObject;
//     this.vaultsService = state.vaultsService;
//     this.balance = state.balance;
//     this.fieldController = state.fieldController;
//     this.showingToast = state.showingToast;
//     this.transactionStatus = state.transactionStatus;
//   }
//   @override
//   List<Object> get props => [
//         vaultsService,
//         stakeTokenObject,
//         balance,
//         fieldController,
//         showingToast,
//         transactionStatus
//       ];
// }
//
// class LockLoading extends LockState {
//   LockLoading(LockState state) : super.copy(state);
// }
//
// class LockInit extends LockState {
//   LockInit(StakeTokenObject object) : super.init(object);
// }
//
// class LockHasToApprove extends LockState {
//   LockHasToApprove(LockState state,
//       {TransactionStatus? transactionStatus, showingToast})
//       : super.copy(state) {
//     if (transactionStatus != null) {
//       this.transactionStatus = transactionStatus;
//       this.showingToast = true;
//     } else {
//       this.showingToast = false;
//     }
//     if (showingToast != null) this.showingToast = showingToast;
//   }
// }
//
// class LockPendingApprove extends LockState {
//   LockPendingApprove(LockState state,
//       {TransactionStatus? transactionStatus, showingToast})
//       : super.copy(state) {
//     if (transactionStatus != null) {
//       this.transactionStatus = transactionStatus;
//       this.showingToast = true;
//     } else {
//       this.showingToast = false;
//     }
//     if (showingToast != null) this.showingToast = showingToast;
//   }
// }
//
// class LockPendingLock extends LockState {
//   LockPendingLock(LockState state,
//       {TransactionStatus? transactionStatus, showingToast})
//       : super.copy(state) {
//     if (transactionStatus != null) {
//       this.transactionStatus = transactionStatus;
//       this.showingToast = true;
//     } else {
//       this.showingToast = false;
//     }
//     if (showingToast != null) this.showingToast = showingToast;
//   }
// }
//
// class LockIsApproved extends LockState {
//   LockIsApproved(LockState state,
//       {TransactionStatus? transactionStatus, showingToast})
//       : super.copy(state) {
//     if (transactionStatus != null) {
//       this.transactionStatus = transactionStatus;
//       this.showingToast = true;
//     } else {
//       this.showingToast = false;
//     }
//     if (showingToast != null) this.showingToast = showingToast;
//   }
// }
