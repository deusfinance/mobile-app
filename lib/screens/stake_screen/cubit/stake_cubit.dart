import 'package:bloc/bloc.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/stake/stake_token_object.dart';
import 'package:deus_mobile/models/swap/gas.dart';
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
    return await state.stakeService
        .getTokenBalance(state.stakeTokenObject.stakeToken.getTokenName());
  }

  Future getAllowances() async {
    emit(StakePendingApprove(state));
    state.stakeTokenObject.stakeToken.allowances = await state.stakeService
        .getAllowances(state.stakeTokenObject.stakeToken.getTokenName());
    if (state.stakeTokenObject.stakeToken.getAllowances() > BigInt.zero)
      emit(StakeIsApproved(state));
    else
      emit(StakeHasToApprove(state));
  }

  Future<void> approve() async {
    emit(StakePendingApprove(state,
        transactionStatus: TransactionStatus(
            "Approve ${state.stakeTokenObject.stakeToken.name}",
            Status.PENDING,
            "Transaction Pending")));

    try {
      var res = await state.stakeService
          .approve(state.stakeTokenObject.stakeToken.getTokenName());
      Stream<TransactionReceipt> result =
          state.stakeService.ethService.pollTransactionReceipt(res);
      result.listen((event) {
        if (event.status) {
          emit(StakeIsApproved(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.stakeTokenObject.stakeToken.name}",
                  Status.SUCCESSFUL,
                  "Transaction Successful",
                  res)));
        } else {
          emit(StakeHasToApprove(state,
              transactionStatus: TransactionStatus(
                  "Approve ${state.stakeTokenObject.stakeToken.name}",
                  Status.FAILED,
                  "Transaction Failed",
                  res)));
        }
      });
    } on Exception catch (value) {
      emit(StakeHasToApprove(state,
          transactionStatus: TransactionStatus(
              "Approve ${state.stakeTokenObject.stakeToken.name}",
              Status.FAILED,
              "Transaction Failed")));
    }
  }

  makeTransaction() async {
    Transaction transaction = await state.stakeService.makeStakeTransaction(
        state.stakeTokenObject.stakeToken.getTokenName(),
        state.fieldController.text);
    return transaction;
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
    if (state.stakeTokenObject.stakeToken.getAllowances() >=
        EthereumService.getWei(input)) {
      if (state.stakeTokenObject.stakeToken.getAllowances() == BigInt.zero)
        emit(StakeHasToApprove(state));
      else
        emit(StakeIsApproved(state));
    } else {
      emit(StakeHasToApprove(state));
    }
  }

  Future<void> stake(Gas gas) async {
    assert(state is StakeIsApproved);
    if(gas!=null) {
      try {
        var res = await state.stakeService.stake(
            state.stakeTokenObject.stakeToken.getTokenName(),
            state.fieldController.text, gas);
        emit(StakePendingStake(state,
            transactionStatus: TransactionStatus(
                "Stake ${state.stakeTokenObject.stakeToken.name}",
                Status.PENDING,
                "Transaction Pending", res)));

        Stream<TransactionReceipt> result =
        state.stakeService.ethService.pollTransactionReceipt(res);
        result.listen((event) {
          if (event.status) {
            emit(StakeIsApproved(state,
                transactionStatus: TransactionStatus(
                    "Stake ${state.fieldController.text} ${state
                        .stakeTokenObject.stakeToken.name}",
                    Status.SUCCESSFUL,
                    "Transaction Successful",
                    res)));
            emit(StakeIsApproved(state));
          } else {
            emit(StakeIsApproved(state,
                transactionStatus: TransactionStatus(
                    "Stake ${state.stakeTokenObject.stakeToken.name}",
                    Status.FAILED,
                    "Transaction Failed",
                    res)));
          }
        });
      } on Exception catch (value) {
        emit(StakeIsApproved(state,
            transactionStatus: TransactionStatus(
                "Stake ${state.stakeTokenObject.stakeToken.name}",
                Status.FAILED,
                "Transaction Failed")));
      }
    }else{
      emit(StakeIsApproved(state,
          transactionStatus: TransactionStatus(
              "Stake ${state.stakeTokenObject.stakeToken.name}",
              Status.FAILED,
              "Rejected")));
    }
    // assert(state is StakeIsApproved || state is StakePendingApproveMergedButton);
  }

  void closeToast() {
    if (state is StakeIsApproved)
      emit(StakeIsApproved(state, showingToast: false));
    else if (state is StakePendingApprove)
      emit(StakePendingApprove(state, showingToast: false));
    else if (state is StakeHasToApprove)
      emit(StakeHasToApprove(state, showingToast: false));
    else if (state is StakePendingStake)
      emit(StakePendingStake(state, showingToast: false));
  }
}
