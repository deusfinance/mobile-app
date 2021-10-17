// import '../../../data_source/currency_data.dart';
// import '../../../locator.dart';
// import '../../../models/stake/stake_token_object.dart';
// import '../../../service/config_service.dart';
// import '../../../service/ethereum_service.dart';
// import '../../../service/stake_service.dart';
// import 'package:equatable/equatable.dart';
//
// abstract class StakingVaultOverviewState extends Equatable {
//   late List<StakeTokenObject> stakeTokenObjects;
//   late StakeTokenObject nativeBalancer;
//   late StakeService stakeService;
//
//   StakingVaultOverviewState.init() {
//     stakeTokenObjects = [];
//     stakeService = new StakeService(
//         ethService: new EthereumService(1),
//         privateKey: locator<ConfigurationService>().getPrivateKey()!);
//
//     stakeTokenObjects
//         .add(new StakeTokenObject(CurrencyData.dea, CurrencyData.sand_dea));
//     stakeTokenObjects
//         .add(new StakeTokenObject(CurrencyData.deus, CurrencyData.sand_deus));
//     stakeTokenObjects.add(
//         new StakeTokenObject(CurrencyData.timeToken, CurrencyData.timeToken));
//
//     nativeBalancer = new StakeTokenObject(CurrencyData.bpt, CurrencyData.bpt);
//   }
//   StakingVaultOverviewState.copy(StakingVaultOverviewState state) {
//     this.stakeService = state.stakeService;
//     this.stakeTokenObjects = state.stakeTokenObjects;
//     this.nativeBalancer = state.nativeBalancer;
//   }
//
//   @override
//   List<Object> get props => [stakeTokenObjects, stakeService, nativeBalancer];
// }
//
// class StakingVaultOverviewInitState extends StakingVaultOverviewState {
//   StakingVaultOverviewInitState() : super.init();
// }
//
// class StakingVaultOverviewErrorState extends StakingVaultOverviewState {
//   StakingVaultOverviewErrorState() : super.init();
// }
//
// class StakingVaultOverviewLoadingState extends StakingVaultOverviewState {
//   StakingVaultOverviewLoadingState(state) : super.copy(state);
// }
//
// class StakingVaultOverviewSingleState extends StakingVaultOverviewState {
//   StakingVaultOverviewSingleState(state) : super.copy(state);
// }
//
// class StakingVaultOverviewLiquidityState extends StakingVaultOverviewState {
//   StakingVaultOverviewLiquidityState(state) : super.copy(state);
// }
