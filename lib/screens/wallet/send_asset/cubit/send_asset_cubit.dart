import '../../../../core/database/database.dart';
import '../../../../core/database/transaction.dart';
import '../../../../core/database/user_address.dart';
import '../../../../core/database/wallet_asset.dart';
import '../../../../locator.dart';
import '../../../../models/swap/gas.dart';
import '../../../../models/transaction_status.dart';
import 'send_asset_state.dart';
import '../../../../service/address_service.dart';
import '../../../../service/wallet_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3dart/web3dart.dart';

class SendAssetCubit extends Cubit<SendAssetState> {
  SendAssetCubit(
      {required WalletAsset walletAsset, required WalletService walletService})
      : super(SendAssetInitialState(walletAsset, walletService));

  Future<void> init() async {
    emit(SendAssetLoadingState(state));
    // ignore: invalid_use_of_protected_member
    if (!state.recAddressController.hasListeners)
      state.recAddressController.addListener(() {
        final String text = state.recAddressController.text.toString();
        if (text.startsWith("0x") && text.length == 42) {
          state.addressConfirmed = true;
          emit(SendAssetLoadingState(state));
          emit(SendAssetLoadedState(state));
        } else {
          state.addressConfirmed = false;
          emit(SendAssetLoadingState(state));
          emit(SendAssetLoadedState(state));
        }
      });
    state.database = await AppDatabase.getInstance();
    emit(SendAssetLoadedState(state));
  }

  void setMax() {
    state.amountController.text = state.walletAsset.balance ?? "0";
    emit(SendAssetLoadingState(state));
    emit(SendAssetLoadedState(state));
  }

  Stream<List<UserAddress>> getUserAddresses() {
    return state.database!.userAddressDao.getAllUserAddresses();
  }

  Future<Transaction?> makeTransferTransaction() async {
    final Transaction? transaction = await state.walletService
        .makeTransferTransaction(
            state.walletAsset.tokenAddress,
            state.recAddressController.text.toString(),
            state.amountController.text.toString());
    return transaction;
  }

  Future<void> transfer(Gas? gas) async {
    if (!state.isInProgress) {
      if (gas != null) {
        DbTransaction? transaction;
        try {
          emit(TransactionPendingState(state,
              transactionStatus: TransactionStatus(
                  "Transfer ${state.walletAsset.tokenName}",
                  Status.PENDING,
                  "Transaction Pending")));
          final res = await state.walletService.transfer(
              state.walletAsset.tokenAddress,
              state.recAddressController.text.toString(),
              state.amountController.text.toString(),
              gas);

          transaction = new DbTransaction(
              walletAddress:
                  (await locator<AddressService>().getPublicAddress()).hex,
              chainId: state.walletAsset.chainId,
              hash: res,
              type: TransactionType.SEND.index,
              title: state.walletAsset.tokenSymbol ??
                  state.walletAsset.tokenAddress);
          final List<int> ids = await state.database!.transactionDao
              .insertDbTransaction([transaction]);
          transaction.id = ids[0];

          emit(SendAssetLoadingState(state));
          emit(TransactionPendingState(state,
              transactionStatus: TransactionStatus(
                  "Transfer ${state.walletAsset.tokenName}",
                  Status.PENDING,
                  "Transaction Pending",
                  res)));
          final Stream<TransactionReceipt> result =
              state.walletService.pollTransactionReceipt(res);
          result.listen((event) async {
            transaction!.isSuccess = event.status;
            await state.database!.transactionDao
                .updateDbTransactions([transaction]);

            if (event.status!) {
              final double newBalance =
                  double.parse(state.walletAsset.balance ?? "0") -
                      double.parse(state.amountController.text.toString());
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
        } on Exception {
          if (transaction != null) {
            transaction.isSuccess = false;
            await state.database!.transactionDao
                .updateDbTransactions([transaction]);
          } else {
            transaction = new DbTransaction(
                walletAddress:
                    (await locator<AddressService>().getPublicAddress()).hex,
                chainId: state.walletAsset.chainId,
                hash: "",
                type: TransactionType.SEND.index,
                title: state.walletAsset.tokenSymbol ??
                    state.walletAsset.tokenAddress);
            final List<int> ids = await state.database!.transactionDao
                .insertDbTransaction([transaction]);
            transaction.id = ids[0];
          }

          emit(TransactionFinishedState(state,
              transactionStatus: TransactionStatus(
                  "Transfer ${state.walletAsset.tokenName}",
                  Status.FAILED,
                  "Transaction Failed")));
        }
      } else {
        emit(TransactionFinishedState(state,
            transactionStatus: TransactionStatus(
                "Transfer ${state.walletAsset.tokenName}",
                Status.FAILED,
                "Transaction Rejected")));
      }
    } else {
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

  void setAddress(UserAddress address) {
    state.recAddressController.text = address.address;
    emit(SendAssetLoadedState(state));
  }
}
