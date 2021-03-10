import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_screen.dart';
import 'package:flutter/material.dart';
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
import '../screens/wallet/wallet_screen.dart';
import '../screens/wallet_intro_screen/intro_page.dart';
import '../screens/wallet_intro_screen/wallet_create_page.dart';
import '../screens/wallet_intro_screen/wallet_import_page.dart';
import '../service/config_service.dart';


const kInitialRoute = '/';

Map<String, WidgetBuilder> generateRoutes(BuildContext appContext) {
  return {
    kInitialRoute: (BuildContext ctx) {
      if (locator<ConfigurationService>().didSetupWallet()) {
        return SwapScreen();
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
    SwapScreen.route: (_) => SwapScreen(),
    StakeScreen.url: (_) => StakeScreen(),
    LockScreen.url: (_) => LockScreen(),
    SyntheticsScreen.url: (_) => SyntheticsScreen(),
    StakingVaultOverviewScreen.url: (_) => StakingVaultOverviewScreen(),
  };
  // return MaterialPageRoute(builder: (BuildContext context) => screen);
}
