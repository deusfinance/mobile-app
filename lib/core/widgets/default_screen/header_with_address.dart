import '../../util/clipboard.dart';
import '../../util/crypto_util.dart';
import '../svg.dart';
import '../../../infrastructure/wallet_provider/wallet_handler.dart';
import '../../../infrastructure/wallet_provider/wallet_provider.dart';
import '../../../routes/navigation_service.dart';
import '../../../screens/wallet_settings_screen/wallet_settings_screen.dart';
import '../../../service/address_service.dart';
import '../../../statics/my_colors.dart';
import '../../../statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';

import '../../../locator.dart';

class HeaderWithAddress extends StatefulWidget {
  final String? walletAddress;
  final Widget? chainSelector;
  HeaderWithAddress({this.walletAddress, this.chainSelector});

  @override
  _HeaderWithAddressState createState() => _HeaderWithAddressState();
}

class _HeaderWithAddressState extends State<HeaderWithAddress> {
  late Future<EthereumAddress> futurePublicAddress;

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
        widget.chainSelector!,
        const Spacer(),
        _buildWalletLogout(walletStore),
      ],
    );
  }

  InkWell _buildWalletLogout(WalletHandler walletStore) {
    return InkWell(
        onTap: () {
          locator<NavigationService>()
              .navigateTo(WalletSettingsScreen.url, context);
        },
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: PlatformSvg.asset('images/logout.svg')));
  }

  Container _buildAddressContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          border: Border.all(
              color: const Color(MyColors.kAddressBackground).withOpacity(0.5)),
          color: const Color(MyColors.kAddressBackground).withOpacity(0.25),
          borderRadius: const BorderRadius.all(Radius.circular(6))),
      child: this.widget.walletAddress != null
          ? _buildAddress(widget.walletAddress!)
          : FutureBuilder(
              future: futurePublicAddress,
              builder: (_, snapshot) {
                if (snapshot.hasData)
                  return _buildAddress((snapshot.data! as EthereumAddress).hex);
                else
                  return const Center(child: CircularProgressIndicator());
              }),
    );
  }

  Widget _buildAddress(String address) {
    return InkWell(
        onTap: () {
          locator<NavigationService>()
              .navigateTo(WalletSettingsScreen.url, context);
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
