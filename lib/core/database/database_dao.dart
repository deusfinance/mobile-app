import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:floor/floor.dart';

import 'chain.dart';

@dao
abstract class WalletAssetDao {
  @Query('SELECT * FROM WalletAsset')
  Future<List<WalletAsset>> getAllWalletAssets();
  //
  // @Query('SELECT * FROM Person WHERE id = :id')
  // Stream<Person?> findPersonById(int id);

  @insert
  Future<void> insertWalletAsset(WalletAsset walletAsset);
}

@dao
abstract class ChainDao {
  @Query('SELECT * FROM Chain')
  Future<List<Chain>> getAllChains();
  //
  // @Query('SELECT * FROM Person WHERE id = :id')
  // Stream<Person?> findPersonById(int id);
  //
  // @insert
  // Future<void> insertWalletAsset(walletAsset);
}