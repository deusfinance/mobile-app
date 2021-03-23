import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class IConfigurationService {
  Future<void> setMnemonic(String value);
  Future<void> setupDone(bool value);
  Future<void> setupPasswordDone(bool value);
  Future<void> setPrivateKey(String value);
  Future<void> setPassword(String value);
  String getMnemonic();
  String getPassword();
  String getPrivateKey();
  bool didSetupWallet();
  bool didSetupPassword();
}

/// Service for saving configuration and wallet access on the local device.
///
/// Usage with locator: `locator<ConfigurationService>()`
class ConfigurationService implements IConfigurationService {
  final FlutterSecureStorage _storage;
  ConfigurationService(this._storage);

  /// temporary copy of the values stored in the local storage.
  Map<String, String> _values;

  static const _kMnemonicKey = "mnemonic";
  static const _kPrivateKey = "privateKey";
  static const _kWalletSetup = "didSetupWallet";
  static const _passwordSetup = "didSetupPassword";
  static const _password = "password";

  /// initially sets all the data saved in the secure storage.
  ///
  /// Enables synchronous access to the saved values.
  Future<void> readTemporaryValues() async {
    _values = await _storage.readAll();
  }

  Future<void> _write(String key, String value) async {
    await _storage.write(key: key, value: value);
    _values[key] = value;
  }

  @override
  Future<void> setMnemonic(String value) async {
    await _write(_kMnemonicKey, value);
  }

  @override
  Future<void> setPrivateKey(String value) async {
    await _write(_kPrivateKey, value);
  }

  @override
  Future<void> setupDone(bool value) async {
    await _write(_kWalletSetup, value.toString());
  }

  @override
  String getMnemonic() {
    return _values[_kMnemonicKey];
  }

  @override
  String getPrivateKey() {
    return _values[_kPrivateKey];
  }

  @override
  bool didSetupWallet() {
    return (_values[_kWalletSetup]?.toLowerCase() ?? 'false') == 'true';
  }

  @override
  bool didSetupPassword() {
    return (_values[_passwordSetup]?.toLowerCase() ?? 'false') == 'true';
  }

  @override
  String getPassword() {
    return _values[_password];
  }

  @override
  Future<void> setPassword(String value) async {
    await _write(_password, value);
  }

  @override
  Future<void> setupPasswordDone(bool value) async {
    await _write(_passwordSetup, value.toString());
  }
}
