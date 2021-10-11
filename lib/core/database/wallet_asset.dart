import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as provider;

@Entity(tableName: 'WalletAsset',
  // foreignKeys: [
  //   ForeignKey(
  //     childColumns: ['chain_id'],
  //     parentColumns: ['id'],
  //     entity: Chain,
  //   )
  // ],
)
class WalletAsset {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'chain_id')
  int chainId;
  String walletAddress;
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


  WalletAsset({this.id, required this.walletAddress, required this.chainId, required this.tokenAddress, this.tokenSymbol,
      this.tokenDecimal, this.valueWhenInserted, this.logoPath, this.tokenName});

  double getValuePercentage() {
    return 12;
  }
}

extension PathCheck on String {
  bool get isSvg => this.endsWith('.svg');
  bool get isNetwork => this.startsWith('http');

  Widget showCircleImage({double radius = 20}) => isNetwork
      ? showCircleNetworkImage()
      : CircleAvatar(
      radius: radius,
      backgroundImage: isSvg
          ? provider.Svg('assets/$this') as ImageProvider
          : AssetImage('assets/$this'));

  Widget showCircleNetworkImage({double radius = 20}) =>
      CircleAvatar(radius: radius, backgroundImage: NetworkImage(this));

  Widget showImage({double? size}) => isSvg
      ? PlatformSvg.asset(this, height: size, width: size)
      : Image.asset('assets/' + this, height: size, width: size);
}
