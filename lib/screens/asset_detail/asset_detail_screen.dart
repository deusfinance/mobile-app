import 'dart:ui';

import 'package:deus_mobile/core/util/clipboard.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/selection_button.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/asset_detail/cubit/asset_detail_cubit.dart';
import 'package:deus_mobile/screens/asset_detail/cubit/asset_detail_state.dart';
import 'package:deus_mobile/screens/wallet/send_asset/send_asset_screen.dart';
import 'package:deus_mobile/service/address_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AssetDetailScreen extends StatefulWidget {
  static const route = "/asset_detail";

  @override
  _AssetDetailScreenState createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  @override
  void initState() {
    context.read<AssetDetailCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetDetailCubit, AssetDetailState>(
        builder: (context, state) {
      if (state is AssetDetailLoadingState) {
        return DefaultScreen(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is AssetDetailErrorState) {
        return DefaultScreen(
          child: Center(
            child: Icon(Icons.refresh, color: MyColors.White),
          ),
        );
      } else if (state is AssetDetailLoadedState) {
        return DefaultScreen(
          child: _buildBody(state),
        );
      } else
        return Container();
    });
  }

  _buildBody(AssetDetailState state) {
    print(state.walletAsset.logoPath);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                state.walletAsset.tokenSymbol ?? "--",
                style: MyStyles.whiteBigTextStyle,
              ),
            ),
          ),
          Divider(
            height: 10,
            thickness: 2,
            color: Colors.grey.withOpacity(0.2),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: state.walletAsset.logoPath != null && state.walletAsset.logoPath != ""
                    ? state.walletAsset.logoPath!.showCircleImage(radius: 15)

                    : Image.asset(
                  "assets/icons/circles.png",
                  width: 50,
                  height: 50,
                ),
              ),
              Text(
                "${state.walletAsset.balance} ${state.walletAsset.tokenSymbol}",
                style: MyStyles.whiteSmallTextStyle,
              ),
            ],
          ),
          blurredPart(state),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  child: SelectionButton(
                    label: 'Send',
                    onPressed: (bool selected) async {
                      locator<NavigationService>().navigateTo(
                          SendAssetScreen.route, context, arguments: {
                        "wallet_asset": state.walletAsset,
                        "wallet_service": state.walletService!
                      });
                    },
                    selected: true,
                    gradient: MyColors.blueToPurpleGradient,
                    textStyle: MyStyles.whiteMediumTextStyle,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  child: SelectionButton(
                    label: 'Receive',
                    onPressed: (bool selected) async {
                      showReceiveBarcode(state);
                    },
                    selected: true,
                    gradient: MyColors.blueToPurpleGradient,
                    textStyle: MyStyles.whiteMediumTextStyle,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget blurredPart(AssetDetailState state) {
    // return BackdropFilter(
    //   filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
    //   child: Column(children: [
    //     // Padding(
    //     //   padding: const EdgeInsets.all(8.0),
    //     //   child: Text(
    //     //     "Equity ${state.walletAsset.getValuePercentage()}%",
    //     //     style: MyStyles.whiteSmallTextStyle,
    //     //   ),
    //     // ),
    //     // Padding(
    //     //   padding: const EdgeInsets.all(8.0),
    //     //   child: Text(
    //     //     "\$ ${state.walletAsset.value ?? "79342"}",
    //     //     style: MyStyles.whiteBigTextStyle,
    //     //   ),
    //     // ),
    //     // Row(
    //     //   children: [
    //     //     Padding(
    //     //         padding: const EdgeInsets.all(8.0),
    //     //         child: state.walletAsset.logoPath!.startsWith('http')
    //     //             ? CircleAvatar(
    //     //                 radius: 15,
    //     //                 backgroundImage:
    //     //                     NetworkImage(state.walletAsset.logoPath!))
    //     //             : CircleAvatar(
    //     //                 radius: 15,
    //     //                 backgroundImage: state.walletAsset.logoPath!
    //     //                         .endsWith('.svg')
    //     //                     ? provider.Svg('assets/$this') as ImageProvider
    //     //                     : AssetImage('assets/$this'))),
    //     //     Text(
    //     //       "${state.walletAsset.balance} ${state.walletAsset.tokenSymbol}",
    //     //       style: MyStyles.whiteSmallTextStyle,
    //     //     ),
    //     //   ],
    //     // ),
    //     // Divider(
    //     //   height: 10,
    //     //   thickness: 2,
    //     //   color: Colors.grey.withOpacity(0.2),
    //     // ),
    //     // Padding(
    //     //   padding: const EdgeInsets.all(8.0),
    //     //   child: Row(
    //     //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     //     children: [
    //     //       Text(
    //     //         "Average Cost",
    //     //         style: MyStyles.lightWhiteSmallTextStyle,
    //     //       ),
    //     //       Text("\$657.24")
    //     //     ],
    //     //   ),
    //     // ),
    //     // Divider(
    //     //   height: 10,
    //     //   thickness: 2,
    //     //   color: Colors.grey.withOpacity(0.2),
    //     // ),
    //     // Padding(
    //     //   padding: const EdgeInsets.all(8.0),
    //     //   child: Row(
    //     //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     //     children: [
    //     //       Text("Profit/Loss", style: MyStyles.lightWhiteSmallTextStyle),
    //     //       Text("568")
    //     //     ],
    //     //   ),
    //     // ),
    //     // Divider(
    //     //   height: 10,
    //     //   thickness: 2,
    //     //   color: Colors.grey.withOpacity(0.2),
    //     // ),
    //     // Padding(
    //     //   padding: const EdgeInsets.all(8.0),
    //     //   child: Row(
    //     //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     //     children: [
    //     //       Text("24h Return", style: MyStyles.lightWhiteSmallTextStyle),
    //     //       Text("568")
    //     //     ],
    //     //   ),
    //     // ),
    //     // Divider(
    //     //   height: 10,
    //     //   thickness: 2,
    //     //   color: Colors.grey.withOpacity(0.2),
    //     // ),
    //   ]),
    //
    // );

    return Container(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            PlatformSvg.asset("icons/coding.svg", height: 100),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text("COMING SOON", style: MyStyles.whiteMediumTextStyle,)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32),
              child: Center(
                  child: Text(
                    "You can see more detail about this token in next versions",
                    style: MyStyles.whiteSmallTextStyle,
                  )),
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ));
  }

  showReceiveBarcode(AssetDetailState state) async {
    String publicAddress =
        (await locator<AddressService>().getPublicAddress()).hex;
    print(publicAddress);
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.center,
        child: Material(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImage(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.all(24),
                  data: publicAddress,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      publicAddress,
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    InkWell(
                        onTap: () async {
                          await copyToClipBoard(publicAddress);
                        },
                        child: Icon(Icons.copy)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
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
  }
}
