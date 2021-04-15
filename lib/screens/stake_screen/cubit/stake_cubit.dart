import 'package:bloc/bloc.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/stake/stake_token_object.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/service/stake_service.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

part 'stake_state.dart';

class StakeCubit extends Cubit<StakeState> {
  StakeCubit(StakeTokenObject object) : super(StakeInit(object));

  init() async {
    emit(StakeLoading(state));
    state.balance = double.tryParse(await getTokenBalance());
    await getAllowances();
    emit(StakeHasToApprove(state));
  }

  getTokenBalance() async {
    print(state.stakeTokenObject.tokenName);
    return await state.stakeService
        .getTokenBalance(state.stakeTokenObject.tokenName);
  }

  Future getAllowances() async {
    emit(StakeHasToApprove(state,
        isInProgress: true));
      state.stakeTokenObject.allowances =
      await state.stakeService.getAllowances(state.stakeTokenObject.tokenName);
      if (state.stakeTokenObject.getAllowances() > BigInt.zero)
        emit(StakeIsApproved(state, isInProgress: false));
      else
        emit(StakeHasToApprove(state,
            isInProgress: false));
      print(state.isInProgress);
  }

  Future<void> approve() async {
    if (!state.isInProgress) {
      emit(StakeTransactionPendingState(state,
          transactionStatus: TransactionStatus(
              "Approve ${state.stakeTokenObject.name}",
              Status.PENDING,
              "Transaction Pending")));

      try {
        var res =
            await state.stakeService.approve(state.stakeTokenObject.tokenName);
        Stream<TransactionReceipt> result =
            state.stakeService.ethService.pollTransactionReceipt(res);
        result.listen((event) {
          if (event.status) {
            emit(StakeTransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    "Approve ${state.stakeTokenObject.name}",
                    Status.SUCCESSFUL,
                    "Transaction Successful",
                    res)));
            emit(StakeIsApproved(state, isInProgress: false));
          } else {
            emit(StakeTransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    "Approve ${state.stakeTokenObject.name}",
                    Status.FAILED,
                    "Transaction Failed",
                    res)));
          }
        });
      } on Exception catch (value) {
        emit(StakeTransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Approve ${state.stakeTokenObject.name}",
                Status.FAILED,
                "Transaction Failed")));
      }
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
    if (state.stakeTokenObject.getAllowances() >=
        EthereumService.getWei(input)) {
      emit(StakeIsApproved(state));
    } else {
      emit(StakeHasToApprove(state));
    }
  }

  Future<void> stake() async {
    if (!state.isInProgress) {
      emit(StakeTransactionPendingState(state,
          transactionStatus: TransactionStatus(
              "Stake ${state.stakeTokenObject.name}",
              Status.PENDING,
              "Transaction Pending")));

      try {
        var res =
        await state.stakeService.stake(state.stakeTokenObject.tokenName, state.fieldController.text);
        Stream<TransactionReceipt> result =
        state.stakeService.ethService.pollTransactionReceipt(res);
        result.listen((event) {
          if (event.status) {
            emit(StakeTransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    "Stake ${state.fieldController.text} ${state.stakeTokenObject.name}",
                    Status.SUCCESSFUL,
                    "Transaction Successful",
                    res)));
            emit(StakeIsApproved(state));
          } else {
            emit(StakeTransactionFinishedState(state,
                transactionStatus: TransactionStatus(
                    "Stake ${state.stakeTokenObject.name}",
                    Status.FAILED,
                    "Transaction Failed",
                    res)));
          }
        });
      } on Exception catch (value) {
        emit(StakeTransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Stake ${state.stakeTokenObject.name}",
                Status.FAILED,
                "Transaction Failed")));
      }
    }
    // assert(state is StakeIsApproved || state is StakePendingApproveMergedButton);
  }

  void closeToast() {
    if (state is StakeTransactionPendingState)
      emit(StakeTransactionPendingState(state, showingToast: false));
    else if (state is StakeTransactionFinishedState)
      emit(StakeTransactionFinishedState(state, showingToast: false));
  }
}
