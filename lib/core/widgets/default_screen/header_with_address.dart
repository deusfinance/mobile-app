import 'package:deus_mobile/core/util/clipboard.dart';
import 'package:deus_mobile/core/util/crypto_util.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/infrastructure/wallet_provider/wallet_handler.dart';
import 'package:deus_mobile/infrastructure/wallet_provider/wallet_provider.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/intro_page.dart';
import 'package:deus_mobile/screens/wallet_settings_screen/wallet_settings_screen.dart';
import 'package:deus_mobile/service/address_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/credentials.dart';

import '../../../locator.dart';

class HeaderWithAddress extends StatefulWidget {
  final String walletAddress;
  final Widget chainSelector;
  HeaderWithAddress({this.walletAddress, this.chainSelector});

  @override
  _HeaderWithAddressState createState() => _HeaderWithAddressState();
}

class _HeaderWithAddressState extends State<HeaderWithAddress> {
  Future<EthereumAddress> futurePublicAddress;

  @override
  void initState() {
    super.initState();
    futurePublicAddress = locator<AddressService>().getPublicAddress();
  }

  @override
  Widget build(BuildContext context) {
    final WalletHandler walletStore = useWallet(context);

    return Row(
      children: [
        _buildAddressContainer(),
        widget.chainSelector,
        const Spacer(),
        _buildWalletLogout(walletStore),
      ],
    );
  }

  GestureDetector _buildWalletLogout(WalletHandler walletStore) {
    return GestureDetector(
        onTap: () {
          locator<NavigationService>().navigateTo(WalletSettingsScreen.url, context);
        },
        child: Container(margin: EdgeInsets.symmetric(horizontal: 6), child: PlatformSvg.asset('images/logout.svg')));
  }

  Container _buildAddressContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          border: Border.all(color: Color(MyColors.kAddressBackground).withOpacity(0.5)),
          color: Color(MyColors.kAddressBackground).withOpacity(0.25),
          borderRadius: BorderRadius.all(Radius.circular(6))),
      child: this.widget.walletAddress != null
          ? _buildAddress(widget.walletAddress)
          : FutureBuilder(
              future: futurePublicAddress,
              builder: (_, snapshot) {
                if (snapshot.hasData)
                  return _buildAddress(snapshot.data.hex);
                else
                  return Center(child: CircularProgressIndicator());
              }),
    );
  }

  Widget _buildAddress(String address) {
    return GestureDetector(
        onTap: () {
          locator<NavigationService>().navigateTo(WalletSettingsScreen.url, context);
        },
        onLongPress: () async => await copyToClipBoard(address),
        child: Center(
          child: Text(
            showShortenedAddress(address),
            style: MyStyles.whiteSmallTextStyle,
          ),
        ));
  }
}
