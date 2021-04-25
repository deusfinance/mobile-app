import 'package:bloc/bloc.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/stake/stake_token_object.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/service/stake_service.dart';
import 'package:deus_mobile/service/vaults_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

part 'lock_state.dart';

class LockCubit extends Cubit<LockState> {
  LockCubit(StakeTokenObject object) : super(LockInit(object));

  init() async {
    emit(LockLoading(state));
    state.balance = double.tryParse(await getTokenBalance());
    await getAllowances();
    emit(LockHasToApprove(state));
  }

  getTokenBalance() async {
    return await state.vaultsService
        .getTokenBalance(state.stakeTokenObject.lockToken.getTokenName());
  }

  Future getAllowances() async {
    emit(LockPendingApprove(state));
    state.stakeTokenObject.lockToken.allowances = await state.vaultsService
        .getAllowances(state.stakeTokenObject.lockToken.getTokenName());
    if (state.stakeTokenObject.lockToken.getAllowances() > BigInt.zero)
      emit(LockIsApproved(state));
    else
      emit(LockHasToApprove(state));
  }

  Future<void> approve() async {
    emit(LockPendingApprove(state,
        transactionStatus: TransactionStatus(
            "Approve ${state.stakeTokenObject.lockToken.name}",
            Status.PENDING,
            "Transaction Pending")));

    try {
      var res = await state.vaultsService
          .approve(state.stakeTokenObject.lockToken.getTokenName());
      Stream<TransactionReceipt> result =
          state.vaultsService.ethService.pollTransactionReceipt(res);
      result.listen((event) {
        if (event.status) {
          emit(LockIsApproved(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.stakeTokenObject.lockToken.name}",
                  Status.SUCCESSFUL,
                  "Transaction Successful",
                  res)));
        } else {
          emit(LockHasToApprove(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.stakeTokenObject.lockToken.name}",
                  Status.FAILED,
                  "Transaction Failed",
                  res)));
        }
      });
    } on Exception catch (value) {
      emit(LockHasToApprove(state,
          transactionStatus: TransactionStatus(
              "Approve ${state.stakeTokenObject.lockToken.name}",
              Status.FAILED,
              "Transaction Failed")));
    }
  }

  addListenerToFromField() {
    if (!state.fieldController.hasListeners) {
      state.fieldController.addListener(() {
        listenInput();
      });
    }
  }

  listenInput() async {
    String input = state.fieldController.text;
    if (input == null || input.isEmpty) {
      input = "0.0";
    }
    if (state.stakeTokenObject.lockToken.getAllowances() >=
        EthereumService.getWei(input)) {
      if (state.stakeTokenObject.lockToken.getAllowances() == BigInt.zero)
        emit(LockHasToApprove(state));
      else
        emit(LockIsApproved(state));
    } else {
      emit(LockHasToApprove(state));
    }
  }

  makeTransaction() async {
    Transaction transaction = await state.vaultsService.makeLockTransaction(
        state.stakeTokenObject.lockToken.getTokenName(),
        state.fieldController.text);
    return transaction;
  }

  Future<void> lock(Gas gas) async {
    assert(state is LockIsApproved);
    if (gas != null) {
      try {
        var res = await state.vaultsService.lock(
            state.stakeTokenObject.lockToken.getTokenName(),
            state.fieldController.text,
            gas);
        emit(LockPendingLock(state,
            transactionStatus: TransactionStatus(
                "Lock ${state.stakeTokenObject.lockToken.name}",
                Status.PENDING,
                "Transaction Pending", res)));
        Stream<TransactionReceipt> result =
            state.vaultsService.ethService.pollTransactionReceipt(res);
        result.listen((event) async {
          if (event.status) {
            state.balance = double.tryParse(await getTokenBalance());
            emit(LockIsApproved(state,
                transactionStatus: TransactionStatus(
                    "Lock ${state.fieldController.text} ${state.stakeTokenObject.lockToken.name}",
                    Status.SUCCESSFUL,
                    "Transaction Successful",
                    res)));
          } else {
            emit(LockIsApproved(state,
                transactionStatus: TransactionStatus(
                    "Lock ${state.stakeTokenObject.lockToken.name}",
                    Status.FAILED,
                    "Transaction Failed",
                    res)));
          }
        });
      } on Exception catch (value) {
        emit(LockIsApproved(state,
            transactionStatus: TransactionStatus(
                "Lock ${state.stakeTokenObject.lockToken.name}",
                Status.FAILED,
                "Transaction Failed")));
      }
    } else {
      emit(LockIsApproved(state,
          transactionStatus: TransactionStatus(
              "Lock ${state.stakeTokenObject.lockToken.name}",
              Status.FAILED,
              "Rejected")));
    }
  }

  void closeToast() {
    if (state is LockIsApproved)
      emit(LockIsApproved(state, showingToast: false));
    else if (state is LockPendingApprove)
      emit(LockPendingApprove(state, showingToast: false));
    else if (state is LockHasToApprove)
      emit(LockHasToApprove(state, showingToast: false));
    else if (state is LockPendingLock)
      emit(LockPendingLock(state, showingToast: false));
  }
}
