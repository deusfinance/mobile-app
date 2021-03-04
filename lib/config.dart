import 'package:flutter/foundation.dart';

class AppConfig {
  /// The currently selected config.
  ///
  /// Can be used to switch between development and production mode easily
  static const selectedConfig = AppConfig.testing();

  const AppConfig.testing() : this.params = const AppConfigParams(chainId: 3);

  final AppConfigParams params;
}

class AppConfigParams {
  const AppConfigParams({@required this.chainId});

  final int chainId;
}
