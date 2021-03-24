import 'package:deus_mobile/core/widgets/token_selector/xdai_stock_selector_screen/xdai_stock_selector_screen.dart';
import 'package:deus_mobile/screens/blurred_stake_lock_screen/blurred_stake_lock_screen.dart';
import 'package:deus_mobile/screens/blurred_synthetics_screen/blurred_synthetics_screen.dart';
import 'package:deus_mobile/screens/password/password_screen.dart';
import 'package:deus_mobile/screens/password/set_password_screen.dart';
import 'package:deus_mobile/screens/stake_screen/cubit/stake_cubit.dart';
import 'package:deus_mobile/screens/staking_vault_overview/staking_vault_overview_screen.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_cubit.dart';
import 'package:deus_mobile/screens/swap/swap_screen.dart';
import 'package:deus_mobile/screens/synthetics/mainnet_synthetics/synthetics_screen.dart';
import 'package:deus_mobile/screens/wallet_settings_screen/wallet_settings_screen.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/xdai_synthetics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../core/widgets/token_selector/currency_selector_screen/currency_selector_screen.dart';
import '../core/widgets/token_selector/stock_selector_screen/stock_selector_screen.dart';
import '../infrastructure/wallet_provider/wallet_provider.dart';
import '../infrastructure/wallet_setup/wallet_setup_provider.dart';
import '../locator.dart';
import '../screens/lock/lock_screen.dart';
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
        return BlocProvider<SwapCubit>(
            create: (_) => SwapCubit(), child: SwapScreen());
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
    WalletImportPage.url: (_) => WalletSetupProvider(
        builder: (_, __) => WalletImportPage("Import wallet")),
    IntroPage.url: (_) => WalletProvider(builder: (_, __) {
          return IntroPage();
        }),
    SetPasswordScreen.url: (_) => SetPasswordScreen(),
    PasswordScreen.url: (_) => PasswordScreen(),
    SplashScreen.route: (_) => SplashScreen(),
    StockSelectorScreen.url: (_) => StockSelectorScreen(),
    CurrencySelectorScreen.url: (_) => CurrencySelectorScreen(),
    XDaiStockSelectorScreen.url: (_) => XDaiStockSelectorScreen(),
    //main screens
    StakeScreen.url: (_) {
      return BlocProvider(
        create: (context) => StakeCubit(),
        child: StakeScreen(),
      );
    },
    SwapScreen.route: (_) => BlocProvider<SwapCubit>(
        create: (_) => SwapCubit(), child: SwapScreen()),
    XDaiSyntheticsScreen.route: (_) => BlocProvider<XDaiSyntheticsCubit>(
        create: (_) => XDaiSyntheticsCubit(), child: XDaiSyntheticsScreen()),
    LockScreen.url: (_) => LockScreen(),
    // SyntheticsScreen.url: (_) => SyntheticsScreen(),
    StakingVaultOverviewScreen.url: (_) => StakingVaultOverviewScreen(),
    //blurred screens (coming soon)
    BlurredStakeLockScreen.url: (_) => BlurredStakeLockScreen(),
    BlurredSyntheticsScreen.url: (_) => BlurredSyntheticsScreen(),
    //Wallet screens
    WalletSettingsScreen.url: (_) => WalletSettingsScreen(),
  };
  // print("Fading to ${settings.name}");
  final Widget screenChild = routes[settings.name](context);
  //TODO (@CodingDavid8): Replace hooks with cubit :)
  final Widget screenWithWallet =
      WalletProvider(builder: (_, __) => screenChild);
  return _getPageRoute(screenWithWallet, settings);
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
