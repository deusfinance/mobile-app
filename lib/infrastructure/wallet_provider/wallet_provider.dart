
import 'package:deus/models/wallet/wallet.dart';
import 'package:deus/service/address_service.dart';
import 'package:deus/service/config_service.dart';
import 'package:deus/service/ethereum_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:provider/provider.dart';


import '../hook_provider.dart';
import 'wallet_state.dart';
import 'wallet_handler.dart';

class WalletProvider extends ContextProviderWidget<WalletHandler> {
  WalletProvider({Widget child, HookWidgetBuilder<WalletHandler> builder})
      : super(child: child, builder: builder);

  @override
  Widget build(BuildContext context) {
    final store =
        useReducer<Wallet, WalletAction>(reducer, initialState: Wallet());

    final addressService = Provider.of<AddressService>(context);
    final ethereumService = Provider.of<EthereumService>(context);
    final configurationService = Provider.of<ConfigurationService>(context);
    final handler = useMemoized(
      () => WalletHandler(
        store,
        addressService,
        ethereumService,
        configurationService,
      ),
      [addressService, store],
    );

    return provide(context, handler);
  }
}

WalletHandler useWallet(BuildContext context) {
  var handler = Provider.of<WalletHandler>(context);

  return handler;
}
