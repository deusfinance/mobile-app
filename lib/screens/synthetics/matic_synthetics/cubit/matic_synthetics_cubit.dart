import 'dart:async';

import 'file:///D:/flutter%20projects/mobile-app/lib/data_source/sync_data/bsc_stock_data.dart';
import 'package:deus_mobile/core/widgets/default_screen/sync_chain_selector.dart';
import 'package:deus_mobile/data_source/currency_data.dart';
import 'file:///D:/flutter%20projects/mobile-app/lib/data_source/sync_data/heco_stock_data.dart';
import 'file:///D:/flutter%20projects/mobile-app/lib/data_source/sync_data/matic_stock_data.dart';
import 'file:///D:/flutter%20projects/mobile-app/lib/data_source/sync_data/stock_data.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/models/synthetics/stock_address.dart';
import 'package:deus_mobile/models/synthetics/contract_input_data.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';
import 'package:intl/intl.dart';

class MaticSyntheticsCubit extends SyntheticsCubit {
  MaticSyntheticsCubit() : super(SyntheticsChain.MATIC);

  bool isBuy() => state.fromToken.getTokenName() == "usdc";
}
