// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_asset_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletAssetApi _$WalletAssetApiFromJson(Map<String, dynamic> json) {
  return WalletAssetApi(
    json['symbol'] as String,
    json['address'] as String,
    json['decimals'],
    json['img'] as String,
  );
}

Map<String, dynamic> _$WalletAssetApiToJson(WalletAssetApi instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'address': instance.address,
      'decimals': instance.decimals,
      'img': instance.img,
    };
