import 'package:deus/service/ethereum_service.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/single_child_widget.dart';
import 'package:web_socket_channel/io.dart';

import '../config.dart';
import 'address_service.dart';
import 'config_service.dart';

Future<List<Provider>> createProviders() async {
  final params = AppConfig.selectedConfig.params;

  final sharedPrefs = await SharedPreferences.getInstance();

  final configurationService = ConfigurationService(sharedPrefs);
  final addressService = AddressService(configurationService);
  final ethereumService = EthereumService(params.chainId);

  return [
    Provider<ConfigurationService>.value(value: configurationService),
    Provider<AddressService>.value(value: addressService),
    Provider<EthereumService>.value(value: ethereumService),
  ];
}
