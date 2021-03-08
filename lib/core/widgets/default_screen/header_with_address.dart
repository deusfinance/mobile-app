import 'package:deus_mobile/core/util/crypto_util.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/service/address_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';

import '../../../locator.dart';



class HeaderWithAddress extends StatefulWidget {
  final String walletAddress;
  HeaderWithAddress({this.walletAddress});

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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(color: Color(MyColors.kAddressBackground).withOpacity(0.5)),
              color: Color(MyColors.kAddressBackground).withOpacity(0.25),
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: this.widget.walletAddress != null
              ? _buildAddress(widget.walletAddress)
              : FutureBuilder(future: futurePublicAddress, builder: (_, snapshot) {
                if(snapshot.hasData) return _buildAddress(snapshot.data.hex);
                else return Center(child: CircularProgressIndicator());
              }),
        ),
        const Spacer(),
        PlatformSvg.asset('images/logout.svg'),
      ],
    );
  }

  Widget _buildAddress(String address) {
    return Center(
      child: Text(
        showShortenedAddress(address),
        style: MyStyles.whiteSmallTextStyle,
      ),
    );
  }
}
