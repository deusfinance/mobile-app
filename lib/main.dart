import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'route_generator.dart';
import 'service/services_provider.dart';
import 'statics/my_colors.dart';
import 'statics/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final List<Provider> providers = await createProviders();
  runApp(DEUSApp(providers));
}

class DEUSApp extends StatelessWidget {
  final List<Provider> providers;

  const DEUSApp(this.providers, {Key key}) : super(key: key);

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
            backgroundColor: Color(MyColors.Background),
            brightness: Brightness.dark,
            canvasColor: Color(MyColors.Background),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routes: generateRoutes(context),
          initialRoute: '/',
        ));
  }
}
