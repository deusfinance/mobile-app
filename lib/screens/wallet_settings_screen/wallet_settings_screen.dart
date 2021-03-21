import 'package:deus_mobile/core/widgets/dark_button.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/intro_page.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

class WalletSettingsScreen extends StatefulWidget {
  static const url = '/wallet-settings';

  static const List<String> _testWalletAddresses = [
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
    '93475zadfjbvökadsfjbv',
  ];

  @override
  _WalletSettingsScreenState createState() => _WalletSettingsScreenState();
}

class _WalletSettingsScreenState extends State<WalletSettingsScreen> {
  bool _walletSelected = false;
  int _selectedWalletIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      child: _walletSelected ? _buildLogOutWalletBody() : _buildListBody(),
    );
  }

  Container _buildLogOutWalletBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 45),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
      decoration: BoxDecoration(
          color: MyColors.ToastRed.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: MyColors.ToastRed)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
          ),
          Text(
            'WARNING',
            style:
                MyStyles.whiteBigTextStyle.copyWith(color: MyColors.ToastRed),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Without your seed phrase or private key you can\'restore your wallet balance!',
            style: MyStyles.whiteMediumTextStyle
                .copyWith(color: MyColors.ToastRed),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    _walletSelected = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: MyColors.ToastGreen),
                      color: MyColors.Button_BG_Black),
                  child: Center(
                    child: Text(
                      'CANCEL',
                      style: MyStyles.whiteSmallTextStyle
                          .copyWith(color: MyColors.ToastGreen),
                    ),
                  ),
                ),
              )),
              SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _walletSelected = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: MyColors.ToastRed),
                        color: MyColors.Button_BG_Black),
                    child: Center(
                      child: Text(
                        'RESET WALLET',
                        style: MyStyles.whiteSmallTextStyle
                            .copyWith(color: MyColors.ToastRed),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30)
        ],
      ),
    );
  }

  Widget _buildListBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              'Your Wallet',
              style: MyStyles.whiteBigTextStyle,
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap:() => locator<NavigationService>().navigateTo(IntroPage.url, context),
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: MyColors.Button_BG_Black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(5),
                  border:
                  Border.all(color: MyColors.Light_Grey.withOpacity(0.4))),
              child: Row(
                children: [
                  PlatformSvg.asset('icons/addWalletIcon.svg'),
                  SizedBox(
                    width: 12,
                  ),
                  Text('Add Wallet'),
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (ctx, ind) => _buildWalletListTile(
                  WalletSettingsScreen._testWalletAddresses[ind],
                  _selectedWalletIndex == ind),
              separatorBuilder: (_, __) => SizedBox(
                    height: 10,
                  ),
              itemCount: WalletSettingsScreen._testWalletAddresses.length),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildWalletListTile(String walletAddress, bool selected) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.only(left: 16, right: 10, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: selected ? MyColors.Selected_Grey : MyColors.Button_BG_Black,
        border: Border.all(color: MyColors.Light_Grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment:
            selected ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
        children: [
          if (selected) Icon(Icons.check),
          if (selected)
            SizedBox(
              width: 10,
            ),
          Text(
            '${walletAddress.substring(0, 8)}...${walletAddress.substring(walletAddress.length - 4)}',
            style: MyStyles.whiteSmallTextStyle,
          ),
          if (selected) Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _walletSelected = true;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: MyColors.ToastRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: MyColors.ToastRed)),
              child: Text(
                'LOG OUT',
                style: MyStyles.whiteMediumTextStyle
                    .copyWith(fontSize: 12.5, color: MyColors.ToastRed),
              ),
            ),
          )
        ],
      ),
    );
  }
}
