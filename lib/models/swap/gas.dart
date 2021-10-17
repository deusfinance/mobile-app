class Gas {
  double? _gasPrice;
  int? _gasLimit;
  int? _nonce;

  int getGasPrice() {
    return (gasPrice * 1000000000).toInt();
  }

  int get nonce => _nonce ?? 0;

  set nonce(int? value) {
    _nonce = value;
  }

  int get gasLimit => _gasLimit ?? 0;

  set gasLimit(int? value) {
    _gasLimit = value;
  }

  double get gasPrice => _gasPrice ?? 0.0;

  set gasPrice(double? value) {
    _gasPrice = value;
  }
}
