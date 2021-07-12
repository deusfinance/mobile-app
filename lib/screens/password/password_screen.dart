import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/intro_page.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/widgets/form/paper_input.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';

import '../../locator.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class PasswordScreen extends StatefulWidget {
  static var url = '/password';

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  var passwordController;
  late ConfigurationService configurationService;
  late bool error;

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;

  final darkGrey = Color(0xFF1C1C1C);
  final LinearGradient button_gradient = LinearGradient(colors: [Color(0xFF0779E4), Color(0xFF1DD3BD)]);

  @override
  void initState() {
    error = false;
    passwordController = new TextEditingController();
    configurationService = locator<ConfigurationService>();

    auth.isDeviceSupported().then(
          (isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported),
    );
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
            SizedBox(height: 60,),
            _buildFingerPrint(),
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

  Future<bool> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return false;

    return canCheckBiometrics;
  }

  Future<bool> _canCheckFingerPrint() async {
    if(await _checkBiometrics()){
      List<BiometricType> availableBiometrics;
      try {
        availableBiometrics = await auth.getAvailableBiometrics();
      } on PlatformException catch (e) {
        return false;
      }
      if (!mounted) return false;

      if(availableBiometrics.contains(BiometricType.fingerprint)){
        return true;
      }
      return false;
    }
    else
      return false;
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {

      authenticated = await auth.authenticate(
          localizedReason:
          'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
    } on PlatformException catch (e) {
      return;
    }
    if (!mounted) return;

    if(authenticated){
      if (locator<ConfigurationService>().didSetupWallet()){
        locator<NavigationService>().navigateTo(SwapScreen.route, context,replaceAll: true);
      }else{
        locator<NavigationService>().navigateTo(IntroPage.url, context,replaceAll: true);
      }
    }
  }

  _buildFingerPrint() {
    if(_supportState == _SupportState.unknown){
      return Center(child: CircularProgressIndicator(),);
    }else if(_supportState == _SupportState.supported){
      return FutureBuilder(
          future: _canCheckFingerPrint(),
          builder: (context, snapshot){
        if(snapshot.hasData && snapshot.data!=null){
          if(snapshot.data as bool){
            return InkWell(
              onTap: _authenticateWithBiometrics,
              child: Column(children: [
                Icon(Icons.fingerprint,size: 60,),
                SizedBox(height: 20,),
                Text("Authenticate by fingerPrint", style: TextStyle(fontSize: 12),)
              ],),
            );
          }else{
            return Container();
          }
        }else{
          return CircularProgressIndicator();
        }
      });
    }else{
      return Container();
    }
  }

}
