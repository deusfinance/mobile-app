import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'config.dart';
import 'locator.dart';
import 'service/address_service.dart';
import 'service/config_service.dart';
import 'service/ethereum_service.dart';

class OmniServices {
  Future<void> createOmniServices() async {
    final params = AppConfig.selectedConfig.params;

    if (!locator.isRegistered(instance: ConfigurationService)) {
      try {
        final storage = FlutterSecureStorage();
        locator.registerLazySingleton<ConfigurationService>(() => ConfigurationService(storage));
        await locator<ConfigurationService>().setTemporaryValues();
      } catch (e) {
        print("Error setting up storage access ${e.runtimeType}");
        print(e);
      }
    }
    try {
      if (!locator.isRegistered(instance: AddressService))
        locator.registerLazySingleton<AddressService>(() => AddressService(locator<ConfigurationService>()));
      if (!locator.isRegistered(instance: EthereumService))
        locator.registerLazySingleton<EthereumService>(() => EthereumService(params.chainId));
    } catch (e) {
      print("Error creating providers. ${e.runtimeType}");
      print(e);
    }
  }
}
