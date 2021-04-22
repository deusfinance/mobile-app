import 'dart:ui';

import 'package:deus_mobile/core/util/responsive.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/xdai_synthetics_screen.dart';
import 'package:deus_mobile/screens/wallet_settings_screen/wallet_settings_screen.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

enum SyncChains { xDAI, MAINNET, BSC }

class SyncChainSelector extends StatefulWidget {
  SyncChains selectedChain;

  SyncChainSelector(this.selectedChain);

  @override
  _SyncChainSelectorState createState() => _SyncChainSelectorState();
}

class _SyncChainSelectorState extends State<SyncChainSelector> {
  @override
  Widget build(BuildContext context) {
    return _buildChainContainer();
  }

  Widget _buildChainContainer() {
    return GestureDetector(
      onTap: () {
        showChainSelectDialog();
      },
      child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Color(MyColors.kAddressBackground).withOpacity(0.5)),
              color: Color(MyColors.kAddressBackground).withOpacity(0.25),
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: Row(
            children: [
              Text(
                getChainName(widget.selectedChain),
                style: MyStyles.whiteSmallTextStyle,
              ),
              Spacer(),
              PlatformSvg.asset('images/icons/chevron_down.svg'),
            ],
          )),
    );
  }

  String getChainName(SyncChains chain) {
    switch (chain) {
      case SyncChains.xDAI:
        return "xDai";
      case SyncChains.MAINNET:
        return "Mainnet";
      case SyncChains.BSC:
        return "BSC";
    }
  }

  void showChainSelectDialog() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.center,
        child: Material(
          child: Container(
            width: getScreenWidth(context) - 50,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Color(MyColors.kAddressBackground).withOpacity(0.5)),
                  color: Color(MyColors.kAddressBackground).withOpacity(0.25),
                  borderRadius: BorderRadius.all(Radius.circular(6))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: (){
                        locator<NavigationService>().navigateTo(XDaiSyntheticsScreen.route, context, replace: true);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          getChainName(SyncChains.xDAI),
                          style: MyStyles.whiteMediumTextStyle,
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 10, thickness: 2, color: Color(MyColors.kAddressBackground).withOpacity(0.5),),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: (){
                        locator<NavigationService>().navigateTo(XDaiSyntheticsScreen.route, context, replace: true);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          getChainName(SyncChains.MAINNET),
                          style: MyStyles.whiteMediumTextStyle,
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 10, thickness: 2, color: Color(MyColors.kAddressBackground).withOpacity(0.5),),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: (){
                        locator<NavigationService>().navigateTo(XDaiSyntheticsScreen.route, context, replace: true);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          getChainName(SyncChains.BSC),
                          style: MyStyles.whiteMediumTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
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
