import '../token.dart';
import '../../screens/synthetics/synthetics_state.dart';
import '../../service/ethereum_service.dart';

// ignore: must_be_immutable
class Stock extends Token {
  String? _name;
  String? _sector;
  String? _symbol;
  String? _shortName;
  String? _shortSymbol;
  String? _longName;
  String? _longSymbol;
  String? _logo;

  String? _shortBalance;
  String? _longBalance;
  String? _shortAllowances;
  String? _longAllowances;

  //Mode is Long or Short
  Mode? _mode;

  BigInt? getBalance() {
    if (mode == Mode.LONG)
      return EthereumService.getWei(longBalance);
    else if (mode == Mode.SHORT) return EthereumService.getWei(shortBalance);
    return null;
  }

  BigInt? getAllowances() {
    if (mode == Mode.LONG)
      return EthereumService.getWei(longAllowances);
    else if (mode == Mode.SHORT) return EthereumService.getWei(shortAllowances);
    return null;
  }

  Stock(name, symbol, logo)
      : super(name, symbol, "https://app.deus.finance/" + logo) {
    _name = name;
    _symbol = symbol;
    _logo = logo;
    this.mode = Mode.LONG;
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      json['name'],
      json['symbol'],
      json['logo'],
    )
      ..longSymbol = json['long_symbol'] as String
      ..longName = json['long_name'] as String
      ..shortSymbol = json['short_symbol'] as String
      ..shortName = json['short_name'] as String
      ..sector = json['sector'] as String;
  }

  @override
  String get logoPath => "https://app.deus.finance/" + logo;

  Mode get mode => _mode ?? Mode.NONE;

  set mode(Mode? value) {
    _mode = value;
  }

  String get longAllowances => _longAllowances ?? "0";

  set longAllowances(String value) {
    _longAllowances = value;
  }

  String get shortAllowances => _shortAllowances ?? "0.0";

  set shortAllowances(String value) {
    _shortAllowances = value;
  }

  String get longBalance => _longBalance ?? "0.0";

  set longBalance(String value) {
    _longBalance = value;
  }

  String get shortBalance => _shortBalance ?? "0.0";

  set shortBalance(String value) {
    _shortBalance = value;
  }

  String get logo => _logo ?? "";

  set logo(String value) {
    _logo = value;
  }

  String get longSymbol => _longSymbol ?? "--";

  set longSymbol(String value) {
    _longSymbol = value;
  }

  String get longName => _longName ?? "--";

  set longName(String value) {
    _longName = value;
  }

  String get shortSymbol => _shortSymbol ?? "--";

  set shortSymbol(String value) {
    _shortSymbol = value;
  }

  String get shortName => _shortName ?? "--";

  set shortName(String value) {
    _shortName = value;
  }

  @override
  String get symbol => _symbol ?? "--";

  set symbol(String value) {
    _symbol = value;
  }

  String get sector => _sector ?? "--";

  set sector(String value) {
    _sector = value;
  }

  @override
  String get name => _name ?? "--";

  set name(String value) {
    _name = value;
  }
}
