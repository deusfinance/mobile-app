import 'package:deus_mobile/core/database/chain.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'WalletAsset',
  foreignKeys: [
    ForeignKey(
      childColumns: ['chain_id'],
      parentColumns: ['id'],
      entity: Chain,
    )
  ],
)
class WalletAsset {
  @primaryKey
  final int id;

  @ColumnInfo(name: 'chain_id')
  final int chainId;

  final String tokenName;
  final String tokenSymbol;
  final String tokenLogoPath;

  final double value;

  WalletAsset(this.id, this.chainId, this.tokenName, this.tokenSymbol,
      this.tokenLogoPath, this.value);
}