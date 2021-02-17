import 'package:deus/core/widgets/token_selector/currency_selector_screen/currency_selector_screen.dart';
import 'package:deus/screens/main_screen/main_screen.dart';
import 'package:deus/screens/splash/splash_screen.dart';
import 'package:deus/screens/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/widgets/token_selector/stock_selector_screen/stock_selector_screen.dart';
import 'screens/synthetics/synchronizer_screen.dart';
import 'statics/old_my_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deus Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Monument',
        backgroundColor: MyColors.background.withOpacity(1),
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: generateRoutes(),
      initialRoute: SplashScreen.route,
    );
  }

  RouteFactory generateRoutes() {
    return (settings) {
      final Map<String, dynamic> arguments = settings.arguments;
      Widget screen;
      switch (settings.name) {
        case MainScreen.route:
          screen = MainScreen();
          break;
        case SplashScreen.route:
          screen = SplashScreen();
          break;
        case SwapBackendTestScreen.url:
          screen = SwapBackendTestScreen();
          break;
        case StockSelectorScreen.url:
          screen = StockSelectorScreen();
          break;
        case CurrencySelectorScreen.url:
          screen = CurrencySelectorScreen();
          break;
        
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
