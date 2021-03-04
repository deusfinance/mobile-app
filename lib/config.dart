class AppConfig {
  /// The currently selected config.
  ///
  /// Can be used to switch between development and production mode easily
  static const selectedConfig = AppConfig.testing();

  const AppConfig.testing()
      : this.params = const AppConfigParams(
            "https://ropsten.infura.io/v3/cf6ea736e00b4ee4bc43dfdb68f51093",
            "wss://ropsten.infura.io/ws/v3/cf6ea736e00b4ee4bc43dfdb68f51093",
            "0x8cd408279e966b7e7e1f0b9e5ed8191959d11a19", 3);

  final AppConfigParams params;
}

class AppConfigParams {
  const AppConfigParams(this.web3HttpUrl, this.web3RdpUrl, this.contractAddress, this.chainId);
  final String web3RdpUrl;
  final String web3HttpUrl;
  final String contractAddress;
  final int chainId;
}
