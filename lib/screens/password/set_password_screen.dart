import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/routes/route_generator.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/intro_page.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/widgets/form/paper_input.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetPasswordScreen extends StatefulWidget {
  static var url = '/set_password';

  @override
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  var passwordController;
  var repeatPasswordController;
  ConfigurationService configurationService;
  bool error;
  String errorText;

  final darkGrey = Color(0xFF1C1C1C);
  final LinearGradient button_gradient = LinearGradient(colors: [Color(0xFF0779E4), Color(0xFF1DD3BD)]);

  @override
  void initState() {
    error = false;
    errorText = "";
    passwordController = new TextEditingController();
    repeatPasswordController = new TextEditingController();
    configurationService = locator<ConfigurationService>();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 150,),
              _buildInput(),

            ],
          ),
      ),
    );
  }

  _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 50),
        Text(
          'Set your password',
          style: TextStyle(fontSize: 25),
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            'This will be your password to enter the app. It\'s the only way to log in and can\'t be recovered',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
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
          SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5),
            child: Text(
              'Repeat Password',
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
              controller: repeatPasswordController,
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
                "Set Password",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              onPressed: () {
                checkPassword();
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> checkPassword() async {
    //TODO check password
    if(passwordController.text==""){
      setState(() {
        error = true;
        errorText = "password is empty";
      });
    }else if(passwordController.text != repeatPasswordController.text){
      setState(() {
        error = true;
        errorText = "passwords do not match";
      });
    }else{
      setState(() {
        error = false;
      });
      configurationService.setPassword(passwordController.text);
      await configurationService.setupPasswordDone(true);

      if (locator<ConfigurationService>().didSetupWallet()) {
        locator<NavigationService>().navigateTo(SwapScreen.route, context, replaceAll: true);
      } else {
        locator<NavigationService>().navigateTo(IntroPage.url, context, replaceAll: true);
      }
    }

  }

  _buildErrorText() {
    return Visibility(
      visible: error,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          errorText,
          style: TextStyle(fontSize: 12, color: MyColors.ToastRed),
        ),
      ),
    );
  }
}
