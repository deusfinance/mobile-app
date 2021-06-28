import 'dart:ui';

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/wallet_chain_selector.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/wallet/add_wallet_asset/add_wallet_asset_screen.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    context.read<WalletCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(builder: (context, state) {
      if (state is WalletLoadingState) {
        return DefaultScreen(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
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
              selectedChain: state.selectedChain,
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
    return Column(
      children: [_assets(state)],
    );
  }

  Widget _navbar(WalletState state) {
    TextStyle colorTextStyle = TextStyle(
        fontFamily: MyStyles.kFontFamily,
        fontWeight: FontWeight.w300,
        fontSize: MyStyles.S6,
        decoration: TextDecoration.underline,
        decorationColor: Color(0xff0779E4),
        foreground: Paint()
          ..shader = LinearGradient(
            colors: <Color>[Color(0xff0779E4), Color(0xff1DD3BD)],
          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)));
    TextStyle whiteTextStyle = TextStyle(
      fontFamily: MyStyles.kFontFamily,
      fontWeight: FontWeight.w300,
      fontSize: MyStyles.S6,
      color: MyColors.White,
    );
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              context.read<WalletCubit>().changeTab(0);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Portfilio",
                  style: state is WalletPortfilioState
                      ? colorTextStyle
                      : whiteTextStyle),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<WalletCubit>().changeTab(1);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Manage Transactions",
                  style: state is WalletManageTransState
                      ? colorTextStyle
                      : whiteTextStyle),
            ),
          )
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Assets"),
              ),
              GestureDetector(
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
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Add New Asset"),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.add),
                        )
                      ],
                    )),
              ),
            ],
          ),
          Divider(
            height: 10,
            thickness: 2,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: state.walletAssets.length,
              itemBuilder: (context, index) {
                WalletAsset walletAsset = state.walletAssets[index];
                return walletAssetCard(walletAsset);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 10,
                  thickness: 2,
                  color: Colors.white.withOpacity(0.1),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void onChainSelected(Chain chain) {
    context.read<WalletCubit>().setSelectedChain(chain);
  }

  Future<void> addChain() async {
    Chain? chain = await showAddChainDialog(null);
    if (chain != null) context.read<WalletCubit>().addChain(chain);
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

  Widget walletAssetCard(WalletAsset walletAsset) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(walletAsset.logoPath ?? "")),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("${walletAsset.tokenSymbol ?? "--"} ${walletAsset.balance??"--"}",
                        overflow: TextOverflow.ellipsis),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "\$${walletAsset.valueWhenInserted?.toString() ?? "123"}",
                    overflow: TextOverflow.ellipsis,
                    style: MyStyles.whiteSmallTextStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${walletAsset.getValuePercentage()}% (\$${walletAsset.value?.toString() ?? "16551"})",
                    style: TextStyle(
                      fontSize: MyStyles.S6,
                        color: walletAsset.getValuePercentage() >= 0
                            ? Colors.green
                            : Colors.red),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateChain(Chain ch) async {
    Chain? chain = await showAddChainDialog(ch);
    if (chain != null) context.read<WalletCubit>().updateChain(chain);
  }
}
