import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../../models/wallet/wallet.dart';
import '../../service/address_service.dart';
import '../../service/config_service.dart';
import '../../service/ethereum_service.dart';
import '../hook_provider.dart';
import 'wallet_handler.dart';
import 'wallet_state.dart';

class WalletProvider extends ContextProviderWidget<WalletHandler> {
  WalletProvider({Widget? child, HookWidgetBuilder<WalletHandler>? builder})
      : super(child: child, builder: builder);

  @override
  Widget build(BuildContext context) {
    final addressService = locator<AddressService>();
    final ethereumService = locator<EthereumService>();
    final configurationService = locator<ConfigurationService>();

    final String? privateKey = configurationService.getPrivateKey();
    final store = useReducer<Wallet, WalletAction>(reducer,
        initialState: Wallet(),
        initialAction: InitialiseWallet("", privateKey!));
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
  final handler = Provider.of<WalletHandler>(context);

  return handler;
}
