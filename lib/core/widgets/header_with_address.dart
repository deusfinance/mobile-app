import 'package:deus_mobile/core/util/crypto_util.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

class HeaderWithAddress extends StatelessWidget {
  final String walletAddress;
  HeaderWithAddress({this.walletAddress});

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
          child: Center(
            child: Text(
              showShortenedAddress(walletAddress),
              style: MyStyles.whiteSmallTextStyle,
            ),
          ),
        ),
        const Spacer(),
        PlatformSvg.asset('images/logout.svg'),
      ],
    );
  }
}
