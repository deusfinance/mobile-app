import '../models/crypto_currency.dart';

//TODO (@CodingDavid8) fetch all supported tokens from server
abstract class CurrencyData {
  static const _basePath = 'images/currencies';

  static List<CryptoCurrency> all = [eth, deus, dea, dai,  wbtc, usdc];
  static List<CryptoCurrency> allForDict = [deus, dea, dai, eth, wbtc, usdc, weth];

  static CryptoCurrency deus = CryptoCurrency(
      name: 'DEUS', symbol: 'DEUS', logoPath: '$_basePath/deus.svg');

  static CryptoCurrency dea = CryptoCurrency(
      name: 'DEA', symbol: 'DEA', logoPath: '$_basePath/dea.svg');

  static CryptoCurrency dai = CryptoCurrency(
      name: 'DAI', symbol: 'DAI', logoPath: '$_basePath/dai.png');

  static CryptoCurrency eth = CryptoCurrency(
      name: 'Ethereum', symbol: 'ETH', logoPath: '$_basePath/eth-logo.svg');

  static CryptoCurrency wbtc = CryptoCurrency(
      name: 'WBTC', symbol: 'WBTC', logoPath: '$_basePath/wbtc.png');

  static CryptoCurrency usdc = CryptoCurrency(
      name: 'USDC', symbol: 'USDC', logoPath: '$_basePath/usdc.svg');

  static CryptoCurrency weth = CryptoCurrency(
      name: 'WETH', symbol: 'WETH', logoPath: '$_basePath/eth-logo.svg');
}
