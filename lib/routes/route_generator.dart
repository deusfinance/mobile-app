import 'package:deus_mobile/screens/stake_screen/cubit/stake_cubit.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_cubit.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../core/widgets/token_selector/currency_selector_screen/currency_selector_screen.dart';
import '../core/widgets/token_selector/stock_selector_screen/stock_selector_screen.dart';
import '../infrastructure/wallet_provider/wallet_provider.dart';
import '../infrastructure/wallet_setup/wallet_setup_provider.dart';
import '../locator.dart';
import '../screens/lock/lock_screen.dart';
import '../core/widgets/default_screen/default_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/stake_screen/stake_screen.dart';
import '../screens/wallet_intro_screen/intro_page.dart';
import '../screens/wallet_intro_screen/wallet_create_page.dart';
import '../screens/wallet_intro_screen/wallet_import_page.dart';
import '../service/config_service.dart';

const kInitialRoute = '/';

Route<dynamic> onGenerateRoute(RouteSettings settings, BuildContext context) {
  final Map<String, WidgetBuilder> routes = {
    kInitialRoute: (BuildContext _) {
      if (locator<ConfigurationService>().didSetupWallet()) {
        return BlocProvider<SwapCubit>(create: (_) => SwapCubit(), child: SwapScreen());
      } else {
        return WalletProvider(builder: (_, __) {
          return IntroPage();
        });
      }
    },
    WalletCreatePage.url: (_) {
      return WalletSetupProvider(builder: (__, store) {
        useEffect(() {
          store.generateMnemonic();
          return null;
        }, []);

        return WalletCreatePage("Create wallet");
      });
    },
    WalletImportPage.url: (_) => WalletSetupProvider(builder: (_, __) => WalletImportPage("Import wallet")),
    IntroPage.url: (_) => IntroPage(),
    // SwapBackendTestScreen.url: (_) => SwapBackendTestScreen(),
    SplashScreen.route: (_) => SplashScreen(),
    StockSelectorScreen.url: (_) => StockSelectorScreen(),
    CurrencySelectorScreen.url: (_) => CurrencySelectorScreen(),
    //main screens
    StakeScreen.url: (_) {
      return BlocProvider(
        create: (context) => StakeCubit(),
        child: StakeScreen(),
      );
    },
    SwapScreen.route: (_) => BlocProvider<SwapCubit>(create: (_) => SwapCubit(), child: SwapScreen()),
    LockScreen.url: (_) => LockScreen(),
    SyntheticsScreen.url: (_) => SyntheticsScreen(),
  };
  // print("Fading to ${settings.name}");
  final Widget screenChild = routes[settings.name](context);
  return _getPageRoute(screenChild, settings);
}

PageRoute _getPageRoute(Widget child, RouteSettings settings) {
  return _FadeRoute(child: child, routeName: settings.name);
}

class _FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;

  _FadeRoute({this.child, this.routeName})
      : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              child,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
