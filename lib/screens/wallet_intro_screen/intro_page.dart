import 'dart:ui';

import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/wallet_create_page.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/wallet_import_page.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

import '../../locator.dart';

class IntroPage extends StatelessWidget {
  static const String url = '/intro';

  final LinearGradient button_gradient = LinearGradient(colors: [Color(0xFF0779E4), Color(0xFF1DD3BD)]);

  final darkGrey = Color(0xFF1C1C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColors.Background),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            children: [
              _buildHeader(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImportWallet(context),
                    SizedBox(
                      height: 20,
                    ),
                    _buildCreateNewWallet(context),
                  ],
                ),
              )
            ],
          )),
    );
  }

  Column _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 50),
        Text(
          'Get Started',
          style: TextStyle(fontSize: 25),
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            'You can either import an existing wallet or create a new wallet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Container _buildImportWallet(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(color: darkGrey, borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
      child: OutlineButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
        color: Colors.transparent,
        borderSide: BorderSide(color: Colors.black),
        child: Text(
          "Import wallet",
          style: TextStyle(fontSize: 20),
        ),
        onPressed: () {
          locator<NavigationService>().navigateTo(WalletImportPage.url, context);
        },
      ),
    );
  }

  Container _buildCreateNewWallet(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(gradient: button_gradient, borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
      height: 55,
      width: double.infinity,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
        color: Colors.transparent,
        child: Text(
          "Create new wallet",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        onPressed: () {
          locator<NavigationService>().navigateTo(WalletCreatePage.url, context);
        },
      ),
    );
  }
}
