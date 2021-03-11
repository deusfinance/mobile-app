class Gas {
  double gasPrice = 0.0;
  int gasLimit = 0;
  int nonce = 0;

  int getGasPrice() {
    return (gasPrice * 1000000000).toInt();
  }
//  double getGasPrice() {
//    return gasPrice;
//  }
}
