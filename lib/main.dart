import 'package:deus/screens/main_screen/main_screen.dart';
import 'package:deus/screens/synthetics/synthetics_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoutes(),
      initialRoute: MainScreen.route,
    );
  }
  RouteFactory generateRoutes() {
    return (settings) {
      final Map<String, dynamic> arguments = settings.arguments;
      Widget screen;
      switch (settings.name) {
        case MainScreen.route:
          screen = MainScreen();
//          arguments['id']
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
