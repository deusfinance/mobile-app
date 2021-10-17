import '../locator.dart';
import 'config_service.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../core/util/hd_key.dart';
import 'package:hex/hex.dart';
import 'package:web3dart/credentials.dart';

///Interface for AddressService in order to set up wallet
abstract class IAddressService {
  String? generateMnemonic();
  String? getPrivateKey(String mnemonic);
  Future<EthereumAddress?> getPublicAddress(String privateKey);
  Future<bool> setupFromMnemonic(String mnemonic);
  Future<bool> setupFromPrivateKey(String privateKey);
  String? entropyToMnemonic(String entropyMnemonic);
}

class AddressService implements IAddressService {
  final IConfigurationService _configService;
  AddressService(this._configService);

  @override
  String? generateMnemonic() {
    return bip39.generateMnemonic();
  }

  @override
  String entropyToMnemonic(String entropyMnemonic) {
    return bip39.entropyToMnemonic(entropyMnemonic);
  }

  @override
  String? getPrivateKey(String mnemonic) {
    final String seed = bip39.mnemonicToSeedHex(mnemonic);
    final KeyData master = HDKey.getMasterKeyFromSeed(seed);
    final privateKey = HEX.encode(master.key!);
    return privateKey;
  }

  String? getMnemonic() {
    return bip39
        .entropyToMnemonic(locator<ConfigurationService>().getMnemonic()!);
  }

  @override
  Future<EthereumAddress> getPublicAddress([String? privateKey]) async {
    //if the privateKey wasn't passed, read it from the config (local device).
    privateKey ??= locator<ConfigurationService>().getPrivateKey();

    final private = EthPrivateKey.fromHex(privateKey!);

    final address = await private.extractAddress();
    return address;
  }

  @override
  Future<bool> setupFromMnemonic(String mnemonic) async {
    final cryptMnemonic = bip39.mnemonicToEntropy(mnemonic);
    final privateKey = this.getPrivateKey(cryptMnemonic);

    await _configService.setMnemonic(cryptMnemonic);
    await _configService.setPrivateKey(privateKey);
    await _configService.setupDone(true);
    return true;
  }

  @override
  Future<bool> setupFromPrivateKey(String privateKey) async {
    await _configService.setMnemonic("");
    await _configService.setPrivateKey(privateKey);
    await _configService.setupDone(true);
    return true;
  }
}
