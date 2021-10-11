import 'dart:typed_data';

import 'package:floor/floor.dart';
import 'package:web3dart/web3dart.dart';

enum TransactionType{APPROVE, SWAP, BUY, SELL, SEND, CANCEL, SPEEDUP}

@entity
class DbTransaction {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String hash;
  String walletAddress;
  int chainId;
  int type;
  String title;
  bool? isSuccess;

  @ignore
  int? nonce;
  @ignore
  Uint8List? data;
  @ignore
  EthereumAddress? from;
  @ignore
  EtherAmount? gasPrice;
  @ignore
  EthereumAddress? to;
  @ignore
  EtherAmount? value;
  @ignore
  int? maxGas;
  @ignore
  BlockNum? blockNum;


  DbTransaction({this.id, required this.walletAddress, required this.chainId, required this.hash, required this.type, required this.title, this.isSuccess});

  String getTitle(){
    switch(type){
      case 0:
        return "APPROVE: ${title}";
      case 1:
        return "SWAP: ${title}";
      case 2:
        return "BUY: ${title}";
      case 3:
        return "SELL: ${title}";
      case 4:
        return "SEND: ${title}";
      case 5:
        return "CANCEL: ${title}";
      case 6:
        return "SPEED UP: ${title}";
    }
    return "";
  }

  getDate(Web3Client web3client){

  }
}