import 'package:deus_mobile/models/swap/crypto_currency.dart';

class StakeTokenObject{
  double apy;
  String stakedAmount;
  String pendingReward;
  CryptoCurrency lockToken;
  CryptoCurrency stakeToken;

  StakeTokenObject(this.lockToken, this.stakeToken);

  bool isValueStaked(){
    double res = double.tryParse(stakedAmount);
    if(res != null && res>0)
      return true;
    return false;
  }

  double percOfPool(){
    return 0.12;
  }

}