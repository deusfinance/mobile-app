import 'dart:async';

import 'file:///D:/flutter%20projects/mobile-app/lib/data_source/sync_data/bsc_stock_data.dart';
import 'package:deus_mobile/data_source/currency_data.dart';
import 'file:///D:/flutter%20projects/mobile-app/lib/data_source/sync_data/stock_data.dart';
import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/models/synthetics/stock_address.dart';
import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';
import 'package:intl/intl.dart';

class BscSyntheticsCubit extends SyntheticsCubit {
  BscSyntheticsCubit() : super(SyntheticsChain.BSC);

  fromTokenChanged(Token selectedToken) async {
    state.toToken = CurrencyData.busd;
    state.fromToken = selectedToken;
    (state.fromToken as Stock).mode = Mode.LONG;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;

    if (checkMarketClosed(selectedToken, Mode.LONG)) {
      state.marketClosed = true;
      emit(SyntheticsLoadingState(state));
      emit(SyntheticsAssetSelectedState(state,
          fromToken: selectedToken, mode: Mode.LONG));
    } else {
      state.marketClosed = false;
      emit(SyntheticsAssetSelectedState(state,
          fromToken: selectedToken, mode: Mode.LONG, isInProgress: true));

      await getAllowances();
      (selectedToken as Stock).longBalance =
      await getTokenBalance(selectedToken);
      emit(SyntheticsAssetSelectedState(state,
          fromToken: selectedToken, isInProgress: false));
    }
  }

  toTokenChanged(Token selectedToken) async {
    state.fromToken = CurrencyData.busd;
    state.toToken = selectedToken;
    (state.toToken as Stock).mode = Mode.LONG;
    state.fromFieldController.text = "";
    state.toFieldController.text = "";
    state.toValue = 0;

    if (checkMarketClosed(selectedToken, Mode.LONG)) {
      state.marketClosed = true;
      emit(SyntheticsLoadingState(state));
      emit(SyntheticsAssetSelectedState(state,
          toToken: selectedToken, mode: Mode.LONG));
    } else {
      state.marketClosed = false;
      emit(SyntheticsLoadingState(state));
      emit(SyntheticsAssetSelectedState(state,
          toToken: selectedToken, mode: Mode.LONG, isInProgress: true));

      await getAllowances();
      (selectedToken as Stock).longBalance =
      await getTokenBalance(selectedToken);
      emit(SyntheticsAssetSelectedState(state,
          toToken: selectedToken, isInProgress: false));
    }
  }

  bool isBuy() => state.fromToken.getTokenName() == "busd";
}
