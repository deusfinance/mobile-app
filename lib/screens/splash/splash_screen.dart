import 'package:deus/data_source/stock_data.dart';
import 'package:deus/screens/main_screen/main_screen.dart';
import 'package:deus/screens/test_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const route = "/splash";
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    _init();
  }

  _init() async{
    StockData.getdata();
    await StockData.getStockAddress();
    Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.route, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Splash"),),
    );
  }
}
