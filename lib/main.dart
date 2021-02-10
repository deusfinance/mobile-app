import 'package:deus/screens/main_screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        case SynchronizerScreen.url:
          screen = SynchronizerScreen();
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
