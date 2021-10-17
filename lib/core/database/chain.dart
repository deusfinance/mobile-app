import 'wallet_asset.dart';
import 'package:floor/floor.dart';

@entity
class Chain {
  @primaryKey
  int id;

  String name;

  String RPC_url;

  String? blockExplorerUrl;

  String? currencySymbol;

  @ignore
  WalletAsset? mainAsset;

  Chain(
      {required this.id,
      required this.name,
      required this.RPC_url,
      this.blockExplorerUrl,
      this.currencySymbol,
      this.mainAsset});
}
