import 'package:deus/core/util/crypto_util.dart';
import 'package:deus/core/widgets/svg.dart';
import 'package:deus/statics/styles.dart';
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
              border: Border.all(color: Color(0xFF61C0BF).withOpacity(0.5)),
              color: Color(0xFF61C0BF).withOpacity(0.25),
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
