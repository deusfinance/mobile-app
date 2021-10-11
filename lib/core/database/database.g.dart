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

  DbTransactionDao? _transactionDaoInstance;

  UserAddressDao? _userAddressDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `WalletAsset` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `chain_id` INTEGER NOT NULL, `walletAddress` TEXT NOT NULL, `tokenAddress` TEXT NOT NULL, `tokenSymbol` TEXT, `tokenDecimal` INTEGER, `valueWhenInserted` REAL, `logoPath` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Chain` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `RPC_url` TEXT NOT NULL, `blockExplorerUrl` TEXT, `currencySymbol` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `DbTransaction` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `hash` TEXT NOT NULL, `walletAddress` TEXT NOT NULL, `chainId` INTEGER NOT NULL, `type` INTEGER NOT NULL, `title` TEXT NOT NULL, `isSuccess` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UserAddress` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `address` TEXT NOT NULL)');

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

  @override
  DbTransactionDao get transactionDao {
    return _transactionDaoInstance ??=
        _$DbTransactionDao(database, changeListener);
  }

  @override
  UserAddressDao get userAddressDao {
    return _userAddressDaoInstance ??=
        _$UserAddressDao(database, changeListener);
  }
}

class _$WalletAssetDao extends WalletAssetDao {
  _$WalletAssetDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _walletAssetInsertionAdapter = InsertionAdapter(
            database,
            'WalletAsset',
            (WalletAsset item) => <String, Object?>{
                  'id': item.id,
                  'chain_id': item.chainId,
                  'walletAddress': item.walletAddress,
                  'tokenAddress': item.tokenAddress,
                  'tokenSymbol': item.tokenSymbol,
                  'tokenDecimal': item.tokenDecimal,
                  'valueWhenInserted': item.valueWhenInserted,
                  'logoPath': item.logoPath
                },
            changeListener),
        _walletAssetUpdateAdapter = UpdateAdapter(
            database,
            'WalletAsset',
            ['id'],
            (WalletAsset item) => <String, Object?>{
                  'id': item.id,
                  'chain_id': item.chainId,
                  'walletAddress': item.walletAddress,
                  'tokenAddress': item.tokenAddress,
                  'tokenSymbol': item.tokenSymbol,
                  'tokenDecimal': item.tokenDecimal,
                  'valueWhenInserted': item.valueWhenInserted,
                  'logoPath': item.logoPath
                },
            changeListener),
        _walletAssetDeletionAdapter = DeletionAdapter(
            database,
            'WalletAsset',
            ['id'],
            (WalletAsset item) => <String, Object?>{
                  'id': item.id,
                  'chain_id': item.chainId,
                  'walletAddress': item.walletAddress,
                  'tokenAddress': item.tokenAddress,
                  'tokenSymbol': item.tokenSymbol,
                  'tokenDecimal': item.tokenDecimal,
                  'valueWhenInserted': item.valueWhenInserted,
                  'logoPath': item.logoPath
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WalletAsset> _walletAssetInsertionAdapter;

  final UpdateAdapter<WalletAsset> _walletAssetUpdateAdapter;

  final DeletionAdapter<WalletAsset> _walletAssetDeletionAdapter;

  @override
  Future<List<WalletAsset>> getAllWalletAssets(
      int chainId, String walletAddress) async {
    return _queryAdapter.queryList(
        'SELECT * FROM WalletAsset Where chain_id = ?1 AND walletAddress = ?2 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => WalletAsset(id: row['id'] as int?, walletAddress: row['walletAddress'] as String, chainId: row['chain_id'] as int, tokenAddress: row['tokenAddress'] as String, tokenSymbol: row['tokenSymbol'] as String?, tokenDecimal: row['tokenDecimal'] as int?, valueWhenInserted: row['valueWhenInserted'] as double?, logoPath: row['logoPath'] as String?),
        arguments: [chainId, walletAddress]);
  }

  @override
  Stream<List<WalletAsset>> getAllWalletAssetsStream(
      int chainId, String walletAddress) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM WalletAsset Where chain_id = ?1 AND walletAddress = ?2 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => WalletAsset(
            id: row['id'] as int?,
            walletAddress: row['walletAddress'] as String,
            chainId: row['chain_id'] as int,
            tokenAddress: row['tokenAddress'] as String,
            tokenSymbol: row['tokenSymbol'] as String?,
            tokenDecimal: row['tokenDecimal'] as int?,
            valueWhenInserted: row['valueWhenInserted'] as double?,
            logoPath: row['logoPath'] as String?),
        arguments: [chainId, walletAddress],
        queryableName: 'WalletAsset',
        isView: false);
  }

  @override
  Future<WalletAsset?> getWalletAsset(
      int chainId, String tokenAddress, String walletAddress) async {
    return _queryAdapter.query(
        'SELECT * FROM WalletAsset Where chain_id = ?1 AND tokenAddress = ?2 AND walletAddress = ?3',
        mapper: (Map<String, Object?> row) => WalletAsset(id: row['id'] as int?, walletAddress: row['walletAddress'] as String, chainId: row['chain_id'] as int, tokenAddress: row['tokenAddress'] as String, tokenSymbol: row['tokenSymbol'] as String?, tokenDecimal: row['tokenDecimal'] as int?, valueWhenInserted: row['valueWhenInserted'] as double?, logoPath: row['logoPath'] as String?),
        arguments: [chainId, tokenAddress, walletAddress]);
  }

  @override
  Future<List<int>> insertWalletAsset(List<WalletAsset> walletAssets) {
    return _walletAssetInsertionAdapter.insertListAndReturnIds(
        walletAssets, OnConflictStrategy.ignore);
  }

  @override
  Future<int> updateCtWalletAsset(List<WalletAsset> walletAssets) {
    return _walletAssetUpdateAdapter.updateListAndReturnChangedRows(
        walletAssets, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteWalletAsset(List<WalletAsset> walletAssets) {
    return _walletAssetDeletionAdapter
        .deleteListAndReturnChangedRows(walletAssets);
  }
}

class _$ChainDao extends ChainDao {
  _$ChainDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _chainInsertionAdapter = InsertionAdapter(
            database,
            'Chain',
            (Chain item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'RPC_url': item.RPC_url,
                  'blockExplorerUrl': item.blockExplorerUrl,
                  'currencySymbol': item.currencySymbol
                },
            changeListener),
        _chainUpdateAdapter = UpdateAdapter(
            database,
            'Chain',
            ['id'],
            (Chain item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'RPC_url': item.RPC_url,
                  'blockExplorerUrl': item.blockExplorerUrl,
                  'currencySymbol': item.currencySymbol
                },
            changeListener),
        _chainDeletionAdapter = DeletionAdapter(
            database,
            'Chain',
            ['id'],
            (Chain item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'RPC_url': item.RPC_url,
                  'blockExplorerUrl': item.blockExplorerUrl,
                  'currencySymbol': item.currencySymbol
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Chain> _chainInsertionAdapter;

  final UpdateAdapter<Chain> _chainUpdateAdapter;

  final DeletionAdapter<Chain> _chainDeletionAdapter;

  @override
  Stream<List<Chain>> getAllChains() {
    return _queryAdapter.queryListStream('SELECT * FROM Chain',
        mapper: (Map<String, Object?> row) => Chain(
            id: row['id'] as int,
            name: row['name'] as String,
            RPC_url: row['RPC_url'] as String,
            blockExplorerUrl: row['blockExplorerUrl'] as String?,
            currencySymbol: row['currencySymbol'] as String?),
        queryableName: 'Chain',
        isView: false);
  }

  @override
  Future<List<int>> insertChain(List<Chain> chains) {
    return _chainInsertionAdapter.insertListAndReturnIds(
        chains, OnConflictStrategy.replace);
  }

  @override
  Future<int> updateChains(List<Chain> chains) {
    return _chainUpdateAdapter.updateListAndReturnChangedRows(
        chains, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteChains(List<Chain> chains) {
    return _chainDeletionAdapter.deleteListAndReturnChangedRows(chains);
  }
}

class _$DbTransactionDao extends DbTransactionDao {
  _$DbTransactionDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _dbTransactionInsertionAdapter = InsertionAdapter(
            database,
            'DbTransaction',
            (DbTransaction item) => <String, Object?>{
                  'id': item.id,
                  'hash': item.hash,
                  'walletAddress': item.walletAddress,
                  'chainId': item.chainId,
                  'type': item.type,
                  'title': item.title,
                  'isSuccess':
                      item.isSuccess == null ? null : (item.isSuccess! ? 1 : 0)
                },
            changeListener),
        _dbTransactionUpdateAdapter = UpdateAdapter(
            database,
            'DbTransaction',
            ['id'],
            (DbTransaction item) => <String, Object?>{
                  'id': item.id,
                  'hash': item.hash,
                  'walletAddress': item.walletAddress,
                  'chainId': item.chainId,
                  'type': item.type,
                  'title': item.title,
                  'isSuccess':
                      item.isSuccess == null ? null : (item.isSuccess! ? 1 : 0)
                },
            changeListener),
        _dbTransactionDeletionAdapter = DeletionAdapter(
            database,
            'DbTransaction',
            ['id'],
            (DbTransaction item) => <String, Object?>{
                  'id': item.id,
                  'hash': item.hash,
                  'walletAddress': item.walletAddress,
                  'chainId': item.chainId,
                  'type': item.type,
                  'title': item.title,
                  'isSuccess':
                      item.isSuccess == null ? null : (item.isSuccess! ? 1 : 0)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DbTransaction> _dbTransactionInsertionAdapter;

  final UpdateAdapter<DbTransaction> _dbTransactionUpdateAdapter;

  final DeletionAdapter<DbTransaction> _dbTransactionDeletionAdapter;

  @override
  Stream<List<DbTransaction>> getAllDbTransactions(
      int chainId, String walletAddress) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM DbTransaction Where chainId = ?1 AND walletAddress = ?2 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => DbTransaction(
            id: row['id'] as int?,
            walletAddress: row['walletAddress'] as String,
            chainId: row['chainId'] as int,
            hash: row['hash'] as String,
            type: row['type'] as int,
            title: row['title'] as String,
            isSuccess: row['isSuccess'] == null
                ? null
                : (row['isSuccess'] as int) != 0),
        arguments: [chainId, walletAddress],
        queryableName: 'DbTransaction',
        isView: false);
  }

  @override
  Future<List<int>> insertDbTransaction(List<DbTransaction> transactions) {
    return _dbTransactionInsertionAdapter.insertListAndReturnIds(
        transactions, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateDbTransactions(List<DbTransaction> transactions) {
    return _dbTransactionUpdateAdapter.updateListAndReturnChangedRows(
        transactions, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteDbTransactions(List<DbTransaction> transactions) {
    return _dbTransactionDeletionAdapter
        .deleteListAndReturnChangedRows(transactions);
  }
}

class _$UserAddressDao extends UserAddressDao {
  _$UserAddressDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _userAddressInsertionAdapter = InsertionAdapter(
            database,
            'UserAddress',
            (UserAddress item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'address': item.address
                },
            changeListener),
        _userAddressUpdateAdapter = UpdateAdapter(
            database,
            'UserAddress',
            ['id'],
            (UserAddress item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'address': item.address
                },
            changeListener),
        _userAddressDeletionAdapter = DeletionAdapter(
            database,
            'UserAddress',
            ['id'],
            (UserAddress item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'address': item.address
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserAddress> _userAddressInsertionAdapter;

  final UpdateAdapter<UserAddress> _userAddressUpdateAdapter;

  final DeletionAdapter<UserAddress> _userAddressDeletionAdapter;

  @override
  Stream<List<UserAddress>> getAllUserAddresses() {
    return _queryAdapter.queryListStream('SELECT * FROM UserAddress',
        mapper: (Map<String, Object?> row) => UserAddress(
            id: row['id'] as int?,
            name: row['name'] as String,
            address: row['address'] as String),
        queryableName: 'UserAddress',
        isView: false);
  }

  @override
  Future<List<int>> insertUserAddress(List<UserAddress> userAddresses) {
    return _userAddressInsertionAdapter.insertListAndReturnIds(
        userAddresses, OnConflictStrategy.ignore);
  }

  @override
  Future<int> updateUserAddress(List<UserAddress> userAddresses) {
    return _userAddressUpdateAdapter.updateListAndReturnChangedRows(
        userAddresses, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteUserAddress(List<UserAddress> userAddresses) {
    return _userAddressDeletionAdapter
        .deleteListAndReturnChangedRows(userAddresses);
  }
}
