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
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'chain_id')
  int chainId;

  String tokenAddress;
  String? tokenSymbol;
  int? tokenDecimal;

  double? valueWhenInserted;


  @ignore
  String? balance;

  String? logoPath;

  @ignore
  String? tokenName;

  @ignore
  double? value;


  WalletAsset({required this.chainId, required this.tokenAddress, this.tokenSymbol,
      this.tokenDecimal, this.valueWhenInserted, this.logoPath});

  double getValuePercentage() {
    return 12;
  }
}