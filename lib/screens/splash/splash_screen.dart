import 'package:deus/data_source/stock_data.dart';
import 'package:deus/screens/main_screen/main_screen.dart';
import 'package:deus/screens/test_screen.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/statics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  static const route = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    bool res1 = await StockData.getData();
    bool res2 = await StockData.getStockAddresses();
    if (res1 && res2)
      Navigator.of(context).pushNamedAndRemoveUntil(
          MainScreen.route, (Route<dynamic> route) => false);
    else
      setState(() {
        error = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: MyColors.splashGradient),
            child: Center(
              child: error
                  ? GestureDetector(
                      onTap: () {
                        _init();
                      },
                      child: Icon(
                        Icons.refresh,
                        color: MyColors.White,
                      ))
                  : SvgPicture.asset("assets/images/deus.svg"),
            ),
          ),
//          SvgPicture.asset("assets/images/splash_bg.svg"),
        ],
      ),
    );
  }
}
