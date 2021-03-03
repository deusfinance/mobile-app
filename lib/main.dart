import 'package:deus/config.dart';
import 'package:deus/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/wallet_intro_screen/intro_page.dart';
import 'service/services_provider.dart';
import 'statics/old_my_colors.dart';
  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final stores = await createProviders(AppConfig.selectedConfig.params);

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
      initialRoute: IntroPage.url,
    );
  }

  
}
