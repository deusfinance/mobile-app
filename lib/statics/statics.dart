
import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/core/util/responsive.dart';
import 'package:deus_mobile/data_source/currency_data.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_state.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';
import 'package:deus_mobile/screens/wallet/cubit/wallet_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/transaction_status.dart';
import 'my_colors.dart';
import 'styles.dart';

class Statics{
  static String DB_NAME = 'app_database19.db';
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
      RPC_url:
      "https://Mainnet.infura.io/v3/cf6ea736e00b4ee4bc43dfdb68f51093",
      blockExplorerUrl: "https://mainnet.etherscan.io/tx/",
      currencySymbol: CurrencyData.eth.symbol,
      mainAsset: new WalletAsset(
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
          chainId: 137,
          tokenAddress: zeroAddress,
          tokenSymbol: CurrencyData.eth.symbol,
          tokenName: CurrencyData.eth.name,
          logoPath: CurrencyData.eth.logoPath));


}

showToast(BuildContext context, final TransactionStatus status) {
  Color c;
  switch (status.status) {
    case Status.SUCCESSFUL:
      c = Color(0xFF00D16C);
      break;
    case Status.PENDING:
      c = Color(0xFFC4C4C4);
      break;
    case Status.FAILED:
      c = Color(0xFFD40000);
      break;
    default:
      c = Color(0xFFC4C4C4);
  }

  FToast fToast = new FToast();
  fToast.init(context);

  Widget toast = Container(
    width: getScreenWidth(context),
    margin: EdgeInsets.all(8),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
            Spacer(),
            InkWell(
                onTap: () {
                  fToast.removeCustomToast();
                },
                child: Icon(Icons.close))
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
            child: Icon(Icons.arrow_right_alt_outlined),
          ),
        )
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 8),
  );
}

