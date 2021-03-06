import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'locator.dart';
import 'route_generator.dart';
import 'screens/splash/cubit/splash_cubit.dart';
import 'screens/splash/splash_screen.dart';
import 'statics/styles.dart';

void deusDebugPrint(String s, {int wrapWidth}){
  if(AppConfig.selectedConfig.showDebugMessages) print(s);
}

void main() async {
  debugPrint = deusDebugPrint;
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  setupLocator();
  runApp(DEUSApp());
}

class DEUSApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return BlocProvider<SplashCubit>(
        create: (_) => SplashCubit(),
        child: BlocBuilder<SplashCubit, SplashState>(builder: (context, state) {
          // at the beginning, show a splash screen, when the data hasn't been loaded yet.
          return FutureBuilder(
            future: context.read<SplashCubit>().initializeData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !(state is SplashSuccess))
                return MaterialApp(theme: MyStyles.theme, home: SplashScreen());

              return MaterialApp(
                title: 'Deus Finance',
                debugShowCheckedModeBanner: false,
                theme: MyStyles.theme,
                routes: generateRoutes(context),
                initialRoute: kInitialRoute,
              );
            },
          );
        }));
  }
}
