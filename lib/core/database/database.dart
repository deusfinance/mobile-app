import 'dart:async';

import 'chain.dart';
import 'transaction.dart';
import 'user_address.dart';
import 'wallet_asset.dart';
import 'database_dao.dart';
import '../../statics/statics.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:floor/floor.dart';

part 'database.g.dart'; // the generated code will be there

@Database(
    version: 1, entities: [WalletAsset, Chain, DbTransaction, UserAddress])
abstract class AppDatabase extends FloorDatabase {
  static Future<AppDatabase?>? _appDatabase;

  WalletAssetDao get walletAssetDao;
  ChainDao get chainDao;
  DbTransactionDao get transactionDao;
  UserAddressDao get userAddressDao;

  static Future<AppDatabase?>? getInstance() {
    if (_appDatabase == null) {
      _appDatabase = AppDatabase.constructor();
    }
    return _appDatabase;
  }

  static Future<AppDatabase?> constructor() {
    return $FloorAppDatabase.databaseBuilder(Statics.DB_NAME).build();
  }
}
