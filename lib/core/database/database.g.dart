// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  WalletAssetDao? _walletAssetDaoInstance;

  ChainDao? _chainDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `WalletAsset` (`id` INTEGER NOT NULL, `chain_id` INTEGER NOT NULL, `tokenName` TEXT NOT NULL, `tokenSymbol` TEXT NOT NULL, `tokenLogoPath` TEXT NOT NULL, `value` REAL NOT NULL, FOREIGN KEY (`chain_id`) REFERENCES `Chain` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Chain` (`id` INTEGER NOT NULL, `chainId` INTEGER NOT NULL, `name` TEXT NOT NULL, `RPC_url` TEXT NOT NULL, `blockExplorerUrl` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  WalletAssetDao get walletAssetDao {
    return _walletAssetDaoInstance ??=
        _$WalletAssetDao(database, changeListener);
  }

  @override
  ChainDao get chainDao {
    return _chainDaoInstance ??= _$ChainDao(database, changeListener);
  }
}

class _$WalletAssetDao extends WalletAssetDao {
  _$WalletAssetDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _walletAssetInsertionAdapter = InsertionAdapter(
            database,
            'WalletAsset',
            (WalletAsset item) => <String, Object?>{
                  'id': item.id,
                  'chain_id': item.chainId,
                  'tokenName': item.tokenName,
                  'tokenSymbol': item.tokenSymbol,
                  'tokenLogoPath': item.tokenLogoPath,
                  'value': item.value
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WalletAsset> _walletAssetInsertionAdapter;

  @override
  Future<List<WalletAsset>> getAllWalletAssets() async {
    return _queryAdapter.queryList('SELECT * FROM WalletAsset',
        mapper: (Map<String, Object?> row) => WalletAsset(
            row['id'] as int,
            row['chain_id'] as int,
            row['tokenName'] as String,
            row['tokenSymbol'] as String,
            row['tokenLogoPath'] as String,
            row['value'] as double));
  }

  @override
  Future<void> insertWalletAsset(WalletAsset walletAsset) async {
    await _walletAssetInsertionAdapter.insert(
        walletAsset, OnConflictStrategy.abort);
  }
}

class _$ChainDao extends ChainDao {
  _$ChainDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<List<Chain>> getAllChains() async {
    return _queryAdapter.queryList('SELECT * FROM Chain',
        mapper: (Map<String, Object?> row) => Chain(
            row['id'] as int,
            row['chainId'] as int,
            row['name'] as String,
            row['RPC_url'] as String,
            row['blockExplorerUrl'] as String));
  }
}
