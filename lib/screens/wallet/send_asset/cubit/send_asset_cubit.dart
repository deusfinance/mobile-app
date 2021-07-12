
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/database/transaction.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/wallet/send_asset/cubit/send_asset_state.dart';
import 'package:deus_mobile/service/wallet_service.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3dart/web3dart.dart';

class SendAssetCubit extends Cubit<SendAssetState> {
  SendAssetCubit({required WalletAsset walletAsset, required WalletService walletService}) : super(SendAssetInitialState(walletAsset, walletService));

  init() async {
    emit(SendAssetLoadingState(state));
    if(!state.recAddressController.hasListeners)
      state.recAddressController.addListener(() {
        String text = state.recAddressController.text.toString();
        if(text.startsWith("0x") && text.length == 42){
          state.addressConfirmed = true;
          emit(SendAssetLoadingState(state));
          emit(SendAssetLoadedState(state));
        }else{
          state.addressConfirmed = false;
          emit(SendAssetLoadingState(state));
          emit(SendAssetLoadedState(state));
        }
      });
    state.database = await AppDatabase.getInstance();
    emit(SendAssetLoadedState(state));
  }

  setMax(){
    state.amountController.text = state.walletAsset.balance??"0";
    emit(SendAssetLoadingState(state));
    emit(SendAssetLoadedState(state));
  }

  Future<Transaction?> makeTransferTransaction() async {
    Transaction? transaction = await state.walletService.makeTransferTransaction(
        state.walletAsset.tokenAddress,
            state.recAddressController.text.toString(),
            state.amountController.text.toString());
    return transaction;
  }

  transfer(Gas? gas) async {
    if (!state.isInProgress) {
      if (gas != null) {
        DbTransaction? transaction;
        try {
          var res =
          await state.walletService.transfer(state.walletAsset.tokenAddress, state.recAddressController.text.toString(), state.amountController.text.toString(), gas);

          transaction = new DbTransaction(
              chainId: state.walletAsset.chainId,
              hash: res,
              type: TransactionType.SEND.index,
              title: state.walletAsset.tokenSymbol??state.walletAsset.tokenAddress);
          List<int> ids = await state.database!.transactionDao
              .insertDbTransaction([transaction]);
          transaction.id = ids[0];

          emit(TransactionPendingState(state,
              transactionStatus: TransactionStatus(
                  "Transfer ${state.walletAsset.tokenName}",
                  Status.PENDING,
                  "Transaction Pending",
                  res)));
          Stream<TransactionReceipt> result =
          state.walletService.pollTransactionReceipt(res);
          result.listen((event) async {
            transaction!.isSuccess = event.status;
            int ids = await state.database!.transactionDao
                .updateDbTransactions([transaction]);

            if (event.status!) {
              double newBalance = double.parse(state.walletAsset.balance??"0") - double.parse(state.amountController.text.toString());
              state.walletAsset.balance = newBalance.toString();
              emit(TransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Transfer ${state.walletAsset.tokenName}",
                      Status.SUCCESSFUL,
                      "Transaction Successful",
                      res)));
            } else {
              emit(TransactionFinishedState(state,
                  transactionStatus: TransactionStatus(
                      "Transfer ${state.walletAsset.tokenName}",
                      Status.FAILED,
                      "Transaction Failed",
                      res)));
            }
          });
        } on Exception catch (value) {

          if(transaction != null){
            transaction.isSuccess = false;
            int ids = await state.database!.transactionDao
                .updateDbTransactions([transaction]);
          }

          emit(TransactionFinishedState(state,
              transactionStatus: TransactionStatus(
                  "Transfer ${state.walletAsset.tokenName}",
                  Status.FAILED,
                  "Transaction Failed")));
        }
      }
    }else{
      emit(TransactionFinishedState(state,
          transactionStatus: TransactionStatus(
              "Transfer ${state.walletAsset.tokenName}",
              Status.FAILED,
              "Transaction Failed")));
    }
  }

  void closeToast() {
    if (state is TransactionPendingState)
      emit(TransactionPendingState(state, showingToast: false));
    else if (state is TransactionFinishedState)
      emit(TransactionFinishedState(state, showingToast: false));
  }
}
