
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../../models/wallet/wallet_setup.dart';
import '../../service/address_service.dart';
import '../hook_provider.dart';
import 'wallet_setup_handler.dart';
import 'wallet_setup_state.dart';

class WalletSetupProvider extends ContextProviderWidget<WalletSetupHandler> {
  WalletSetupProvider(
      {Widget child, HookWidgetBuilder<WalletSetupHandler> builder})
      : super(child: child, builder: builder);

  @override
  Widget build(BuildContext context) {
    final store = useReducer<WalletSetup, WalletSetupAction>(reducer,
        initialState: WalletSetup());

    final addressService = locator<AddressService>();
    final handler = useMemoized(
      () => WalletSetupHandler(store, addressService),
      [addressService, store],
    );

    return provide(context, handler);
  }
}

WalletSetupHandler useWalletSetup(BuildContext context) {
  var handler = Provider.of<WalletSetupHandler>(context);

  return handler;
}
