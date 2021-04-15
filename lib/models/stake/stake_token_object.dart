import 'package:deus_mobile/service/ethereum_service.dart';

class StakeTokenObject{
  String name;
  String tokenName;
  double apy;
  String stakedAmount;
  String pendingReward;
  String allowances = "0.0";

  StakeTokenObject(this.name, this.tokenName);
  bool isValueStaked(){
    double res = double.tryParse(stakedAmount);
    if(res != null && res>0)
      return true;
    return false;
  }

  double percOfPool(){
    return 0.12;
  }

  BigInt getAllowances() {
    if(allowances == null)
      return BigInt.zero;
    return EthereumService.getWei(allowances);
  }

}