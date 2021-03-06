import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'core/widgets/token_selector/currency_selector_screen/currency_selector_screen.dart';
import 'core/widgets/token_selector/stock_selector_screen/stock_selector_screen.dart';
import 'infrastructure/wallet_provider/wallet_provider.dart';
import 'infrastructure/wallet_setup/wallet_setup_provider.dart';
import 'locator.dart';
import 'screens/lock/lock_screen.dart';
import 'screens/main_screen/main_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/stake_screen/stake_screen.dart';
import 'screens/wallet_intro_screen/intro_page.dart';
import 'screens/wallet_intro_screen/wallet_create_page.dart';
import 'screens/wallet_intro_screen/wallet_import_page.dart';
import 'service/config_service.dart';

const kInitialRoute = '/';

Map<String, WidgetBuilder> generateRoutes(BuildContext appContext) {
  return {
    kInitialRoute: (BuildContext ctx) {
      final configurationService = locator<ConfigurationService>();

      if (configurationService.didSetupWallet())
        return WalletProvider(builder: (_, __) {
          return SplashScreen();
        });
      else
        return IntroPage();
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
    MainScreen.route: (_) => MainScreen(),
    IntroPage.url: (_) => IntroPage(),

    // SwapBackendTestScreen.url: (_) => SwapBackendTestScreen(),
    SplashScreen.route: (_) => SplashScreen(),
//    SwapBackendTestScreen.url: (_) => SwapBackendTestScreen(),
    StockSelectorScreen.url: (_) => StockSelectorScreen(),
    CurrencySelectorScreen.url: (_) => CurrencySelectorScreen(),
    StakeScreen.url: (_) => StakeScreen(),
    LockScreen.url: (_) => LockScreen(),
  };
  // return MaterialPageRoute(builder: (BuildContext context) => screen);
}
