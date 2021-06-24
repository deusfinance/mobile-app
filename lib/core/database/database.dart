
import 'dart:async';

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/core/database/database_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:floor/floor.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [WalletAsset, Chain])
abstract class AppDatabase extends FloorDatabase {
  WalletAssetDao get walletAssetDao;
  ChainDao get chainDao;
}
