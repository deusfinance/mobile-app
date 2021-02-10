import '../models/crypto_currency.dart';

//TODO (@CodingDavid8) fetch all supported tokens from server
abstract class CurrencyData {
  static const _basePath = 'images/currencies';

  static const List<CryptoCurrency> all = [deus, eth];

  static const CryptoCurrency deus = CryptoCurrency(
      name: 'DEUS', shortName: 'DEUS', logoPath: '$_basePath/deus.svg');
  static const CryptoCurrency eth = CryptoCurrency(
      name: 'Ethereum',
      shortName: 'ETH',
      logoPath: '$_basePath/eth.png');
}
