
import 'dart:async';

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/transaction.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/core/database/database_dao.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:floor/floor.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [WalletAsset, Chain, DbTransaction])
abstract class AppDatabase extends FloorDatabase {
  static Future<AppDatabase?>? _appDatabase;

  WalletAssetDao get walletAssetDao;
  ChainDao get chainDao;
  DbTransactionDao get transactionDao;

  static Future<AppDatabase?>? getInstance(){
    if(_appDatabase == null){
      _appDatabase = AppDatabase.constructor();
    }
    return _appDatabase;
  }

  static Future<AppDatabase?> constructor() {
    return $FloorAppDatabase.databaseBuilder(Statics.DB_NAME).build();
  }
}
