import '../core/database/chain.dart';
import '../core/database/wallet_asset.dart';
import '../core/util/responsive.dart';
import '../data_source/currency_data.dart';
import '../screens/swap/cubit/swap_state.dart';
import '../screens/synthetics/synthetics_state.dart';
import '../screens/wallet/cubit/wallet_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/transaction_status.dart';
import 'styles.dart';

class Statics {
  static String DB_NAME = 'deus_app_database_v1.db';
  static SyntheticsState? xdaiSyncState;
  static SyntheticsState? bscSyncState;
  static SyntheticsState? hecoSyncState;
  static SyntheticsState? ethSyncState;
  static WalletState? walletState;
  static SwapState? swapState;

  static String zeroAddress = "0x0000000000000000000000000000000000000000";
  static Chain eth = new Chain(
      id: 1,
      name: "ETH",
      RPC_url: "https://Mainnet.infura.io/v3/8344fd70eef24c50b3fa252322585913",
      blockExplorerUrl: "https://etherscan.io/tx/",
      currencySymbol: CurrencyData.eth.symbol,
      mainAsset: new WalletAsset(
          walletAddress: "",
          chainId: 1,
          tokenAddress: zeroAddress,
          tokenSymbol: CurrencyData.eth.symbol,
          tokenName: CurrencyData.eth.name,
          logoPath: CurrencyData.eth.logoPath));
  static Chain xdai = new Chain(
      id: 100,
      name: "XDAI",
      RPC_url: "https://rpc.xdaichain.com/",
      blockExplorerUrl: "https://blockscout.com/xdai/mainnet/tx/",
      currencySymbol: CurrencyData.xdai.symbol,
      mainAsset: new WalletAsset(
          walletAddress: "",
          chainId: 100,
          tokenAddress: zeroAddress,
          tokenSymbol: CurrencyData.xdai.symbol,
          tokenName: CurrencyData.xdai.name,
          logoPath: CurrencyData.xdai.logoPath));
  static Chain bsc = new Chain(
      id: 56,
      name: "BSC",
      RPC_url: "https://bsc-dataseed.binance.org/",
      blockExplorerUrl: "https://bscscan.com/tx/",
      currencySymbol: CurrencyData.bnb.symbol,
      mainAsset: new WalletAsset(
          walletAddress: "",
          chainId: 56,
          tokenAddress: zeroAddress,
          tokenSymbol: CurrencyData.bnb.symbol,
          tokenName: CurrencyData.bnb.name,
          logoPath: CurrencyData.bnb.logoPath));
  static Chain heco = new Chain(
      id: 128,
      name: "HECO",
      RPC_url: "https://http-mainnet.hecochain.com/",
      blockExplorerUrl: "https://hecoinfo.com/tx/",
      currencySymbol: CurrencyData.ht.symbol,
      mainAsset: new WalletAsset(
          walletAddress: "",
          chainId: 128,
          tokenAddress: zeroAddress,
          tokenSymbol: CurrencyData.ht.symbol,
          tokenName: CurrencyData.ht.name,
          logoPath: CurrencyData.ht.logoPath));
  static Chain matic = new Chain(
      id: 137,
      name: "MATIC(Polygon)",
      RPC_url: "https://rpc-mainnet.maticvigil.com/",
      blockExplorerUrl: "",
      currencySymbol: CurrencyData.eth.symbol,
      mainAsset: new WalletAsset(
          walletAddress: "",
          chainId: 137,
          tokenAddress: zeroAddress,
          tokenSymbol: CurrencyData.eth.symbol,
          tokenName: CurrencyData.eth.name,
          logoPath: CurrencyData.eth.logoPath));
}

// ignore: type_annotate_public_apis
showToast(BuildContext context, final TransactionStatus status) {
  Color c;
  switch (status.status) {
    case Status.SUCCESSFUL:
      c = const Color(0xFF00D16C);
      break;
    case Status.PENDING:
      c = const Color(0xFFC4C4C4);
      break;
    case Status.FAILED:
      c = const Color(0xFFD40000);
      break;
    default:
      c = const Color(0xFFC4C4C4);
  }

  final FToast fToast = new FToast();
  fToast.init(context);

  final Widget toast = Container(
    width: getScreenWidth(context),
    margin: const EdgeInsets.all(8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: c,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              status.label,
              style: MyStyles.whiteSmallTextStyle,
            ),
            const Spacer(),
            InkWell(
                onTap: () {
                  fToast.removeCustomToast();
                },
                child: const Icon(Icons.close))
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            status.message,
            style: MyStyles.whiteSmallTextStyle,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Transform.rotate(
            angle: 150,
            child: const Icon(Icons.arrow_right_alt_outlined),
          ),
        )
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 8),
  );
}
