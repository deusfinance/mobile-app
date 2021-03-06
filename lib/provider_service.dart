import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'service/address_service.dart';
import 'service/config_service.dart';
import 'service/ethereum_service.dart';

class ProviderService {
  List<Provider> providers = [];

  Future<List<Provider>> createProviders({SharedPreferences sharedPrefs}) async {
    final params = AppConfig.selectedConfig.params;

    final preferences = sharedPrefs ?? await SharedPreferences.getInstance();

    final configurationService = ConfigurationService(preferences);
    final addressService = AddressService(configurationService);
    final ethereumService = EthereumService(params.chainId);

    providers = [
      Provider<ConfigurationService>.value(value: configurationService),
      Provider<AddressService>.value(value: addressService),
      Provider<EthereumService>.value(value: ethereumService),
    ];
    return providers;
  }
}
