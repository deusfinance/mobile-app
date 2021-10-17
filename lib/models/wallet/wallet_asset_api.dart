import 'package:json_annotation/json_annotation.dart';

part 'wallet_asset_api.g.dart';

@JsonSerializable()
class WalletAssetApi {
  String symbol;
  String address;
  // ignore: type_annotate_public_apis
  var decimals;
  String img;

  WalletAssetApi(this.symbol, this.address, this.decimals, this.img);

  factory WalletAssetApi.fromJson(Map<String, dynamic> json) =>
      _$WalletAssetApiFromJson(json);
  Map<String, dynamic> toJson() => _$WalletAssetApiToJson(this);
}
