import 'dart:math';
import 'dart:ui';

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/transaction.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/core/widgets/toast.dart';
import 'package:deus_mobile/core/widgets/wallet_chain_selector.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/asset_detail/asset_detail_screen.dart';
import 'package:deus_mobile/screens/wallet/add_wallet_asset/add_wallet_asset_screen.dart';
import 'package:deus_mobile/screens/wallet/manage_gas.dart';
import 'package:deus_mobile/service/address_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/statics.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

import 'add_chain_screen.dart';
import 'cubit/wallet_cubit.dart';
import 'cubit/wallet_state.dart';

class WalletScreen extends StatefulWidget {
  static const route = "/wallet";

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  @override
  void initState() {
    context.read<WalletCubit>().init(walletState: Statics.walletState);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(listener: (context, state) {
      Statics.walletState = state;
    }, builder: (context, state) {
      if (state is WalletLoadingState) {
        return DefaultScreen(
            child: Center(
              child: CircularProgressIndicator(),
            ),
            chainSelector: WalletChainSelector(
              selectedChain: state.selectedChain,
              chains: state.chains,
              onChainSelected: onChainSelected,
              addChain: addChain,
              deleteChain: deleteChain,
              updateChain: updateChain,
            ));
      } else if (state is WalletErrorState) {
        return DefaultScreen(
          child: Center(
            child: Icon(Icons.refresh, color: MyColors.White),
          ),
        );
      } else {
        return DefaultScreen(
            child: _buildBody(state),
            chainSelector: WalletChainSelector(
              selectedChain: state.selectedChain!,
              chains: state.chains,
              onChainSelected: onChainSelected,
              addChain: addChain,
              deleteChain: deleteChain,
              updateChain: updateChain,
            ));
      }
    });
  }

  Widget _buildBody(WalletState state) {
    return Stack(
      children: [
        Column(
          children: [
            _navbar(state),
            state.walletTab == WalletTab.ASSETS ? _assets(state) : listTransactions(state)
          ],
        ),
        _buildToastWidget(state),
      ],
    );
  }

  Widget _navbar(WalletState state) {
    return Container(
      margin: EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      context.read<WalletCubit>().changeTab(0);
                    });
                  },
                  child: Center(
                      child: Container(
                    child: Text(
                      "Assets",
                      overflow: TextOverflow.ellipsis,
                      style: state.walletTab == WalletTab.ASSETS
                          ? TextStyle(
                              fontFamily: MyStyles.kFontFamily,
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              foreground: Paint()
                                ..shader = MyColors.greenToBlueGradient
                                    .createShader(Rect.fromLTRB(0, 0, 50, 30)))
                          : TextStyle(
                              fontFamily: MyStyles.kFontFamily,
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: MyColors.HalfWhite,
                            ),
                    ),
                  )),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      context.read<WalletCubit>().changeTab(1);
                    });
                  },
                  child: Center(
                      child: Container(
                    child: Text(
                      "Activity",
                      overflow: TextOverflow.ellipsis,
                      style: state.walletTab == WalletTab.ACTIVITY
                          ? TextStyle(
                              fontFamily: MyStyles.kFontFamily,
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              foreground: Paint()
                                ..shader = MyColors.greenToBlueGradient
                                    .createShader(Rect.fromLTRB(0, 0, 50, 30)))
                          : TextStyle(
                              fontFamily: MyStyles.kFontFamily,
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: MyColors.HalfWhite,
                            ),
                    ),
                  )),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 6,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Visibility(
                  visible: state.walletTab == WalletTab.ASSETS,
                  child: Container(
                      margin: EdgeInsets.only(top: 3),
                      height: 2.0,
                      width: 40,
                      decoration: MyStyles.greenToBlueDecoration),
                ),
              ),
              Expanded(
                child: Visibility(
                  visible: state.walletTab == WalletTab.ACTIVITY,
                  child: Container(
                      margin: EdgeInsets.only(top: 3),
                      height: 2.0,
                      width: 60,
                      decoration: MyStyles.greenToBlueDecoration),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _diagram() {
    return Container();
  }

  Widget _assets(WalletState state) {
    return Expanded(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<Stream<List<WalletAsset>>>(
                    future: context.read<WalletCubit>().getWalletAssetsStream(),
                    builder:(context, streamData){
                      if(streamData.connectionState == ConnectionState.waiting || streamData.data == null)
                        return Container();
                      return StreamBuilder<List<WalletAsset>>(
                          stream: streamData.data,
                          builder: (context, snapshot) {
                        return Text(
                          "Assets(${snapshot.connectionState == ConnectionState.waiting ? "--" : snapshot.data?.length ?? 0})",
                          style: TextStyle(
                            fontFamily: MyStyles.kFontFamily,
                            fontWeight: FontWeight.w300,
                            fontSize: MyStyles.S6,
                            color: MyColors.White,
                          ),
                        );
                      });
                    }
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final walletAsset = await locator<NavigationService>()
                      .navigateTo(AddWalletAssetScreen.route, context,
                          arguments: {"chain": state.selectedChain});
                  if (walletAsset != null) {
                    context
                        .read<WalletCubit>()
                        .addWalletAsset(walletAsset as WalletAsset);
                  }
                },
                child: Container(
                    margin: EdgeInsets.fromLTRB(0, 12, 12, 4),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Color(MyColors.kAddressBorder)
                                .withOpacity(0.5)),
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // padding: const EdgeInsets.all(4.0),
                          margin: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.add,
                            color: Color(0xff1DD3BD),
                          ),
                        ),
                        Text("Add Asset",
                            style: TextStyle(
                                fontFamily: MyStyles.kFontFamily,
                                fontWeight: FontWeight.w300,
                                fontSize: MyStyles.S6,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: <Color>[
                                      Color(0xff0779E4),
                                      Color(0xff1DD3BD)
                                    ],
                                  ).createShader(
                                      Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)))),
                      ],
                    )),
              ),
            ],
          ),
          const Divider(
            height: 12,
            thickness: 1,
            color: Colors.black,
          ),
          listWalletAsset(state),
        ],
      ),
    );
  }

  void onChainSelected(Chain chain) {
    context.read<WalletCubit>().setSelectedChain(chain);
  }

  Future<void> addChain() async {
    Chain? chain = await showAddChainDialog(null);
    if (chain != null) {
      context.read<WalletCubit>().addChain(chain);
      // locator<NavigationService>().goBack(context);
    }
  }

  Future<Chain?> showAddChainDialog(Chain? chain) async {
    Chain? res = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
          alignment: Alignment.center,
          child: AddChainScreen(
            chain: chain,
          )),
      barrierDismissible: true,
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          child: child,
          opacity: anim1,
        ),
      ),
      transitionDuration: Duration(milliseconds: 10),
    );
    return res;
  }

  void deleteChain(Chain chain) {
    final Widget dialog = AlertDialog(
      title: Text('Are you sure?'),
      content: Text('Do you want to delete chain ${chain.name}?'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            locator<NavigationService>().goBack(context, false);
          },
          child: Text('No'),
        ),
        FlatButton(
          onPressed: () {
            context.read<WalletCubit>().deleteChain(chain);
            locator<NavigationService>().goBack(context, true);
            locator<NavigationService>().goBack(context, true);
          },
          child: Text('Yes'),
        ),
      ],
    );
    showDialog(context: context, builder: (context) => dialog);
  }

  Widget walletAssetCard(WalletAsset walletAsset, WalletState state) {
    return InkWell(
      onLongPress: () {
        final Widget dialog = AlertDialog(
          title: Text('Are you sure?'),
          content:
              Text('Do you want to delete Asset ${walletAsset.tokenSymbol}?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                locator<NavigationService>().goBack(context, false);
              },
              child: Text('No'),
            ),
            FlatButton(
              onPressed: () {
                context.read<WalletCubit>().deleteWalletAsset(walletAsset);
              },
              child: Text('Yes'),
            ),
          ],
        );
        showDialog(context: context, builder: (context) => dialog);
      },
      onTap: () {
        locator<NavigationService>().navigateTo(
            AssetDetailScreen.route, context, arguments: {
          'wallet_asset': walletAsset,
          "chain": state.selectedChain
        });
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: walletAsset.logoPath != null && walletAsset.logoPath != ""
                  ? walletAsset.logoPath!.showCircleImage(radius: 20)
                  // CircleAvatar(
                  //         radius: 25,
                  //         backgroundImage: NetworkImage(
                  //           walletAsset.logoPath ?? "",
                  //         ))
                  : Image.asset(
                      "assets/icons/circles.png",
                      width: 40,
                      height: 40,
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("${walletAsset.tokenSymbol ?? "--"}",
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      walletAsset.tokenName ?? walletAsset.tokenAddress,
                      style: MyStyles.lightWhiteSmallTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         "\$${walletAsset.valueWhenInserted?.toString() ?? "123"}",
            //         overflow: TextOverflow.ellipsis,
            //         style: MyStyles.whiteSmallTextStyle,
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         "${walletAsset.getValuePercentage()}% (\$${walletAsset.value?.toString() ?? "16551"})",
            //         style: TextStyle(
            //             fontSize: MyStyles.S6,
            //             color: walletAsset.getValuePercentage() >= 0
            //                 ? Colors.green
            //                 : Colors.red),
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ),
            //   ],
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "balance: ${EthereumService.formatDouble(walletAsset.balance ?? "0")}",
                overflow: TextOverflow.ellipsis,
                style: MyStyles.whiteSmallTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Gas?> showConfirmGasFeeDialog(
      WalletState state, Transaction transaction) async {
    Gas? res = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
          alignment: Alignment.center,
          child: ManageGasScreen(
              transaction: transaction, chain: state.selectedChain!)),
      barrierDismissible: true,
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          child: child,
          opacity: anim1,
        ),
      ),
      transitionDuration: Duration(milliseconds: 10),
    );
    return res;
  }

  Widget transactionCard(WalletState state, DbTransaction transaction) {
    return InkWell(
      onLongPress: () {
        final Widget dialog = AlertDialog(
          title: Text('Are you sure?'),
          content:
          Text('Do you want to delete Transaction ${transaction.title}?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                locator<NavigationService>().goBack(context, false);
              },
              child: Text('No'),
            ),
            FlatButton(
              onPressed: () {
                context.read<WalletCubit>().deleteTransaction(transaction);
                locator<NavigationService>().goBack(context, false);
              },
              child: Text('Yes'),
            ),
          ],
        );
        showDialog(context: context, builder: (context) => dialog);
      },
      onTap: () async {
        if (transaction.blockNum!.isPending) {
          String url =
              (state.selectedChain?.blockExplorerUrl ?? "") + transaction.hash;
          await _launchInBrowser(url);
        }
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: transactionCardIcon(transaction),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      transaction.getTitle(),
                      style: MyStyles.whiteMediumTextStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "block No. ${transaction.blockNum?.toString() ?? "---"}",
                      style: MyStyles.lightWhiteSmallTextStyle,
                    ),
                  ),
                ],
              ),
            ),
            transaction.blockNum != null &&
                    (transaction.blockNum?.isPending ?? true)
                ? Container(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () async {
                            Transaction? t = context
                                .read<WalletCubit>()
                                .makeTransactionWithInfo(transaction);
                            Gas? gas = await showConfirmGasFeeDialog(state, t);
                            context.read<WalletCubit>().sendTransaction(gas, t, transaction.title, TransactionType.SPEEDUP);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(8.0)),
                              margin: EdgeInsets.all(4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 20),
                              child: Center(
                                  child: Text(
                                "Speed Up",
                                overflow: TextOverflow.ellipsis,
                              ))),
                        ),
                        InkWell(
                          onTap: () async {
                            Transaction? t = await context
                                .read<WalletCubit>()
                                .makeCancelTransaction(transaction);

                            Gas? gas = await showConfirmGasFeeDialog(state, t);
                            context.read<WalletCubit>().sendTransaction(gas, t, transaction.title, TransactionType.CANCEL);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0)),
                              margin: EdgeInsets.all(4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 20),
                              child: Center(
                                  child: Text(
                                "Cancel",
                                overflow: TextOverflow.ellipsis,
                              ))),
                        ),
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      String url =
                          (state.selectedChain?.blockExplorerUrl ?? "") +
                              transaction.hash;
                      await _launchInBrowser(url);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.all(4),
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                        child: Center(
                            child: Text(
                          "Show Tnx",
                          overflow: TextOverflow.ellipsis,
                        ))),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> updateChain(Chain ch) async {
    Chain? chain = await showAddChainDialog(ch);
    if (chain != null) context.read<WalletCubit>().updateChain(chain);
  }

  Widget listWalletAsset(WalletState state) {
    return Expanded(
      child: FutureBuilder<Stream<List<WalletAsset>>>(
        future: context.read<WalletCubit>().getWalletAssetsStream(),
        builder:(context, streamData) {
          if (streamData.connectionState == ConnectionState.waiting || streamData.data == null)
            return Center(child: CircularProgressIndicator());
          return StreamBuilder<List<WalletAsset>>(
              stream: streamData.data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data?.length == 0) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 150,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformSvg.asset(
                              'icons/empty.svg', height: 50),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("There is no Asset on this Network"),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      WalletAsset walletAsset = snapshot.data![index];
                      return walletAssetCard(walletAsset, state);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 10,
                        thickness: 2,
                        color: Colors.white.withOpacity(0.1),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              });}
      ),
    );
  }

  Widget listTransactions(WalletState state) {
    return Expanded(
      child: FutureBuilder<Stream<List<DbTransaction>>>(
        future: context.read<WalletCubit>().getTransactionsStream(),
        builder: (context, streamData){
          if (streamData.connectionState == ConnectionState.waiting || streamData.data == null)
            return Center(child: CircularProgressIndicator());
          return StreamBuilder<List<DbTransaction>>(
              stream: streamData.data,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  List<DbTransaction> transactions = snapshot.data!;
                  if (transactions.length == 0) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 150,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformSvg.asset('icons/empty.svg', height: 50),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("There is no Transaction on this Network"),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      DbTransaction transaction = transactions[index];
                      return transactionCard(state, transaction);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 10,
                        thickness: 2,
                        color: Colors.white.withOpacity(0.1),
                      );
                    },
                  );
                }
                else {
                  return Center(child: CircularProgressIndicator());
                }
              });
        }
      ),
    );
  }

  transactionCardIcon(DbTransaction transaction) {
    if (transaction.blockNum == null) {
      return PlatformSvg.asset('icons/error.svg', height: 30);
    }
    if (transaction.blockNum?.isPending ?? true) {
      return CircularProgressIndicator(
        backgroundColor: Colors.white,
        valueColor: new AlwaysStoppedAnimation<Color>(MyColors.Main_BG_Black),
        strokeWidth: 2,
      );
    } else if (transaction.isSuccess == false) {
      return PlatformSvg.asset('icons/error.svg', height: 30);
    } else if (transaction.type == TransactionType.APPROVE.index) {
      return PlatformSvg.asset('icons/tick.svg', height: 30);
    } else if (transaction.type == TransactionType.SWAP.index) {
      return Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white, width: 2)),
          child: PlatformSvg.asset('icons/exchange.svg', height: 20));
    } else if (transaction.type == TransactionType.BUY.index) {
      return PlatformSvg.asset('icons/download.svg', height: 30);
    } else if (transaction.type == TransactionType.SELL.index) {
      return PlatformSvg.asset('icons/upload.svg', height: 30);
    } else if (transaction.type == TransactionType.SEND.index) {
      return PlatformSvg.asset('icons/upload.svg', height: 30);
    }else if (transaction.type == TransactionType.CANCEL.index) {
      return PlatformSvg.asset('icons/white_error.svg', height: 30);
    }else if (transaction.type == TransactionType.SPEEDUP.index) {
      return Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white, width: 2)),
          child: RotatedBox(
              quarterTurns: 3,
              child: PlatformSvg.asset('icons/speed_up.svg', height: 17)));
    }
    else
      return Container();
  }

  Widget _buildTransactionPending(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGrey,
        onPressed: () {
          if (transactionStatus.hash != "") {
            // _launchInBrowser();
          }
        },
        onClosed: () {
          context.read<WalletCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionSuccessFul(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGreen,
        onPressed: () {
          // _launchInBrowser(transactionStatus.transactionUrl(chainId: 100)!);
        },
        onClosed: () {
          context.read<WalletCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionFailed(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastRed,
        onPressed: () {
          // _launchInBrowser(transactionStatus.transactionUrl(chainId: 100)!);
        },
        onClosed: () {
          context.read<WalletCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildToastWidget(WalletState state) {
    if (state is WalletTransactionPendingState && state.showingToast) {
      return Align(
          alignment: Alignment.bottomCenter,
          child: _buildTransactionPending(state.transactionStatus));
    } else if (state is WalletTransactionFinishedState &&
        state.showingToast) {
      if (state.transactionStatus.status == Status.PENDING) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionPending(state.transactionStatus));
      } else if (state.transactionStatus.status == Status.SUCCESSFUL) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionSuccessFul(state.transactionStatus));
      } else if (state.transactionStatus.status == Status.FAILED) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionFailed(state.transactionStatus));
      }
    }
    return Container();
  }
}
