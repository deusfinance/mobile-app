import 'dart:ui';

import '../../core/util/clipboard.dart';
import '../../core/widgets/default_screen/default_screen.dart';
import '../../core/widgets/selection_button.dart';
import '../../core/widgets/svg.dart';
import '../../locator.dart';
import '../../routes/navigation_service.dart';
import 'cubit/asset_detail_cubit.dart';
import 'cubit/asset_detail_state.dart';
import '../wallet/send_asset/send_asset_screen.dart';
import '../../service/address_service.dart';
import '../../statics/my_colors.dart';
import '../../core/database/wallet_asset.dart';
import '../../statics/styles.dart';
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
          child: const Center(
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
                child: state.walletAsset.logoPath != null &&
                        state.walletAsset.logoPath != ""
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
                  margin: const EdgeInsets.all(8.0),
                  child: SelectionButton(
                    label: 'Send',
                    onPressed: (bool selected) async {
                      await locator<NavigationService>().navigateTo(
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
                  margin: const EdgeInsets.all(8.0),
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
    return Container(
        child: Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        PlatformSvg.asset("icons/coding.svg", height: 100),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            "COMING SOON",
            style: MyStyles.whiteMediumTextStyle,
          )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32),
          child: Center(
              child: Text(
            "You can see more detail about this token in next versions",
            style: MyStyles.whiteSmallTextStyle,
          )),
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    ));
  }

  void showReceiveBarcode(AssetDetailState state) async {
    final String publicAddress =
        (await locator<AddressService>().getPublicAddress()).hex;
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.center,
        child: Material(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImage(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(24),
                  data: publicAddress,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(
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
                    const SizedBox(
                      width: 12,
                    ),
                    InkWell(
                        onTap: () async {
                          await copyToClipBoard(publicAddress);
                        },
                        child: const Icon(Icons.copy)),
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
      transitionDuration: const Duration(milliseconds: 10),
    );
  }
}
