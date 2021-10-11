import 'package:deus_mobile/core/database/transaction.dart';
import 'package:deus_mobile/core/database/user_address.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:floor/floor.dart';

import 'chain.dart';

@dao
abstract class WalletAssetDao {
  @Query('SELECT * FROM WalletAsset Where chain_id = :chainId AND walletAddress = :walletAddress ORDER BY id DESC')
  Future<List<WalletAsset>> getAllWalletAssets(int chainId, String walletAddress);

  @Query('SELECT * FROM WalletAsset Where chain_id = :chainId AND walletAddress = :walletAddress ORDER BY id DESC')
  Stream<List<WalletAsset>> getAllWalletAssetsStream(int chainId, String walletAddress);

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<List<int>> insertWalletAsset(List<WalletAsset> walletAssets);

  @update
  Future<int> updateCtWalletAsset(List<WalletAsset> walletAssets);

  @delete
  Future<int> deleteWalletAsset(List<WalletAsset> walletAssets);

  @Query(
      'SELECT * FROM WalletAsset Where chain_id = :chainId AND tokenAddress = :tokenAddress AND walletAddress = :walletAddress')
  Future<WalletAsset?> getWalletAsset(int chainId, String tokenAddress, String walletAddress);
}

@dao
abstract class ChainDao {
  @Query('SELECT * FROM Chain')
  Stream<List<Chain>> getAllChains();

  void insertDefaultChains() {

    insertChain([Statics.eth, Statics.xdai, Statics.bsc, Statics.heco, Statics.matic]);
  }

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertChain(List<Chain> chains);

  @update
  Future<int> updateChains(List<Chain> chains);

  @delete
  Future<int> deleteChains(List<Chain> chains);
}

@dao
abstract class UserAddressDao {
  @Query('SELECT * FROM UserAddress')
  Stream<List<UserAddress>> getAllUserAddresses();

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<List<int>> insertUserAddress(List<UserAddress> userAddresses);

  @update
  Future<int> updateUserAddress(List<UserAddress> userAddresses);

  @delete
  Future<int> deleteUserAddress(List<UserAddress> userAddresses);
}


@dao
abstract class DbTransactionDao {
  @Query('SELECT * FROM DbTransaction Where chainId = :chainId AND walletAddress = :walletAddress ORDER BY id DESC')
  Stream<List<DbTransaction>> getAllDbTransactions(int chainId, String walletAddress);

  @insert
  Future<List<int>> insertDbTransaction(List<DbTransaction> transactions);

  @Update()
  Future<int> updateDbTransactions(List<DbTransaction> transactions);

  @delete
  Future<int> deleteDbTransactions(List<DbTransaction> transactions);
}
