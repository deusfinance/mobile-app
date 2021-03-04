import 'package:deus/config.dart';
import 'package:deus/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/wallet_intro_screen/intro_page.dart';
import 'service/services_provider.dart';
import 'statics/old_my_colors.dart';
import 'statics/styles.dart';
  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final List<Provider> providers = await createProviders();
  runApp(MyApp(providers));
}

class MyApp extends StatelessWidget {
  final List<Provider> providers;

  const MyApp(this.providers, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'Deus Finance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: MyStyles.kFontFamily,
          backgroundColor: MyColors.background.withOpacity(1),
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        onGenerateRoute: generateRoutes(context),
        initialRoute: '/',
      ),
    );
  }

  
}
