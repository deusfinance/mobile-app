import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:floor/floor.dart';

import 'chain.dart';

@dao
abstract class WalletAssetDao {
  @Query('SELECT * FROM WalletAsset Where chain_id = :chainId')
  Future<List<WalletAsset>> getAllWalletAssets(int chainId);

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<List<int>> insertWalletAsset(List<WalletAsset> walletAssets);

  @update
  Future<int> updateCtWalletAsset(List<WalletAsset> walletAssets);

  @delete
  Future<int> deleteWalletAsset(List<WalletAsset> walletAssets);

  void insertTestAssets() {
    insertWalletAsset([new WalletAsset(chainId: 1, tokenAddress: "ascasc")]);
  }
}

@dao
abstract class ChainDao {
  @Query('SELECT * FROM Chain')
  Stream<List<Chain>> getAllChains();

  void insertDefaultChains() {
    Chain eth = new Chain(id: 1, name: "ETH", RPC_url: "https://Mainnet.infura.io/v3/cf6ea736e00b4ee4bc43dfdb68f51093", blockExplorerUrl: "");
    Chain xdai = new Chain(id: 100, name: "XDAI", RPC_url: "https://rpc.xdaichain.com/", blockExplorerUrl: "");
    Chain bsc = new Chain(id: 56, name: "BSC", RPC_url: "https://bsc-dataseed.binance.org/", blockExplorerUrl: "");
    Chain heco = new Chain(id: 128, name: "HECO", RPC_url: "https://http-mainnet.hecochain.com/", blockExplorerUrl: "");
    Chain matic = new Chain(id: 137, name: "MATIC", RPC_url: "https://rpc-mainnet.maticvigil.com/", blockExplorerUrl: "");
    insertChain([eth, xdai, bsc, heco, matic]);
  }

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<List<int>> insertChain(List<Chain> chains);

  @update
  Future<int> updateChains(List<Chain> chains);

  @delete
  Future<int> deleteChains(List<Chain> chains);
}