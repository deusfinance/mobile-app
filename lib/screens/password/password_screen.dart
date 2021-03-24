import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/intro_page.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/widgets/form/paper_input.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../locator.dart';

class PasswordScreen extends StatefulWidget {
  static var url = '/password';

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  var passwordController;
  ConfigurationService configurationService;
  bool error;

  final darkGrey = Color(0xFF1C1C1C);
  final LinearGradient button_gradient = LinearGradient(colors: [Color(0xFF0779E4), Color(0xFF1DD3BD)]);

  @override
  void initState() {
    error = false;
    passwordController = new TextEditingController();
    configurationService = locator<ConfigurationService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeader(),
            SizedBox(height: 100,),
            _buildInput(),
          ],
        ),
    );
  }

  _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset("assets/images/deus_dao.svg", height: 70,),
        SizedBox(
          height: 30,
        ),
        SvgPicture.asset("assets/images/deus.svg", height: 30,),
      ],
    );
  }

  _buildInput() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5),
            child: Text(
              'Password',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: darkGrey,
            ),
            child: PaperInput(
              textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              hintText: 'Password',
              maxLines: 1,
              controller: passwordController,
            ),
          ),
          _buildErrorText(),
          SizedBox(height: 30,),
          Container(
            decoration:
            BoxDecoration(gradient: button_gradient, borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
            height: 55,
            width: double.infinity,
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize)),
              color: Colors.transparent,
              child: Text(
                "LOG IN",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              onPressed: () {
                login();
              },
            ),
          ),
        ],
      ),
    );
  }

  void login() {
    if(passwordController.text == configurationService.getPassword()){
      if (locator<ConfigurationService>().didSetupWallet()){
        locator<NavigationService>().navigateTo(SwapScreen.route, context,replaceAll: true);
      }else{
        locator<NavigationService>().navigateTo(IntroPage.url, context,replaceAll: true);
      }
    }else{
      setState(() {
        error = true;
      });
    }

  }

  _buildErrorText() {
    return Visibility(
      visible: error,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
        "password is incorrect",
        style: TextStyle(fontSize: 12, color: MyColors.ToastRed),
      ),
      ),
    );
  }
}
