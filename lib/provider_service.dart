import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'locator.dart';
import 'service/address_service.dart';
import 'service/config_service.dart';
import 'service/ethereum_service.dart';

class OmniServices {
  Future<void> createOmniServices({SharedPreferences sharedPrefs}) async {
    final params = AppConfig.selectedConfig.params;

    final preferences = sharedPrefs ?? await SharedPreferences.getInstance();

    try {
      locator.registerLazySingleton<ConfigurationService>(() => ConfigurationService(preferences));
      locator.registerLazySingleton<AddressService>(() => AddressService(locator<ConfigurationService>()));
      locator.registerLazySingleton<EthereumService>(() => EthereumService(params.chainId));
    }  catch (e) {
      print("runtimeType ${e.runtimeType}");
      print(e);
    }
  }
}
