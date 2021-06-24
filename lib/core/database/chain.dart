import 'package:deus_mobile/models/token.dart';
import 'package:floor/floor.dart';

@entity
class Chain {
  @primaryKey
  int id;

  int chainId;

  String name;

  String RPC_url;

  String blockExplorerUrl;

  Chain(this.id, this.chainId, this.name, this.RPC_url, this.blockExplorerUrl);
}