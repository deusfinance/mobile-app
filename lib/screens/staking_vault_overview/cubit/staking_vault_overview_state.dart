
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/stake/stake_token_object.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/service/stake_service.dart';
import 'package:equatable/equatable.dart';

abstract class StakingVaultOverviewState extends Equatable{
  List<StakeTokenObject> stakeTokenObjects;
  StakeService stakeService;

  StakingVaultOverviewState.init(){
    stakeTokenObjects = [];
    stakeService = new StakeService(ethService: new EthereumService(1), privateKey: locator<ConfigurationService>().getPrivateKey());

    stakeTokenObjects.add(new StakeTokenObject("sDEA", "sand_dea"));
    stakeTokenObjects.add(new StakeTokenObject("sDEUS","sand_deus"));
    stakeTokenObjects.add(new StakeTokenObject("TIME TOKEN","timetoken"));
  }
  StakingVaultOverviewState.copy(StakingVaultOverviewState state){
    this.stakeService = state.stakeService;
    this.stakeTokenObjects = state.stakeTokenObjects;
  }

  @override
  List<Object> get props => [stakeTokenObjects, stakeService];
}

class StakingVaultOverviewInitState extends StakingVaultOverviewState{
  StakingVaultOverviewInitState() : super.init();
}

class StakingVaultOverviewLoadingState extends StakingVaultOverviewState{
  StakingVaultOverviewLoadingState(state) : super.copy(state);
}

class StakingVaultOverviewSingleState extends StakingVaultOverviewState{
  StakingVaultOverviewSingleState(state) : super.copy(state);
}

class StakingVaultOverviewLiquidityState extends StakingVaultOverviewState{
  StakingVaultOverviewLiquidityState(state) : super.copy(state);
}