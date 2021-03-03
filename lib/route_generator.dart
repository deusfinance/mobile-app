import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'core/widgets/token_selector/currency_selector_screen/currency_selector_screen.dart';
import 'core/widgets/token_selector/stock_selector_screen/stock_selector_screen.dart';
import 'infrastructure/wallet_setup/wallet_setup_provider.dart';
import 'screens/lock/lock_screen.dart';
import 'screens/main_screen/main_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/stake_screen/stake_screen.dart';
import 'screens/test_screen.dart';
import 'screens/wallet_intro_screen/intro_page.dart';
import 'screens/wallet_intro_screen/wallet_create_page.dart';
import 'screens/wallet_intro_screen/wallet_import_page.dart';

RouteFactory generateRoutes() {
  return (settings) {
    final Map<String, dynamic> arguments = settings.arguments;
    Widget screen;
    switch (settings.name) {
      case MainScreen.route:
        screen = MainScreen();
        break;
      case WalletImportPage.url:
        screen = WalletSetupProvider(
          builder: (context, store) {
            return WalletImportPage("Import wallet");
          },
        );
        break;
      case WalletCreatePage.url:
        screen = WalletSetupProvider(builder: (context, store) {
          useEffect(() {
            store.generateMnemonic();
            return null;
          }, []);

          return WalletCreatePage("Create wallet");
        });
        break;
      case IntroPage.url:
        screen = IntroPage();
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
      case StakeScreen.url:
        screen = StakeScreen();
        break;
      case LockScreen.url:
        screen = LockScreen();
        break;

      default:
        return null;
    }
    return MaterialPageRoute(builder: (BuildContext context) => screen);
  };
}
