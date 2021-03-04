import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'route_generator.dart';
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
  runApp(DEUSApp(providers));
}

class DEUSApp extends StatelessWidget {
  final List<Provider> providers;

  const DEUSApp(this.providers, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      builder: (ctx, _) {
        final routes = generateRoutes(ctx);
        return MaterialApp(
          title: 'Deus Finance',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: MyStyles.kFontFamily,
            backgroundColor: MyColors.background.withOpacity(1),
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routes: routes,
          initialRoute: '/',
        );
      },
    );
  }
}
