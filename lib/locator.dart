import 'package:get_it/get_it.dart';

import 'provider_service.dart';

GetIt locator = GetIt.instance;

/// Enables easy access to single instances of services.
///
/// Usage:
/// ```dart
/// locator<ServiceClass>().serviceMethodOfThatClass 
/// ```
void setupLocator(){
  locator.registerLazySingleton<ProviderService>(() => ProviderService());
}