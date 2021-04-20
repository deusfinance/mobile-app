
import 'dart:convert';

import 'package:deus_mobile/models/stake/stake_token_object.dart';
import 'package:deus_mobile/screens/staking_vault_overview/cubit/staking_vault_overview_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;


class StakingVaultOverviewCubit extends Cubit<StakingVaultOverviewState>{
  StakingVaultOverviewCubit() : super(StakingVaultOverviewInitState());


  init() async {
    emit(StakingVaultOverviewLoadingState(state));
    await getData();
    emit(StakingVaultOverviewSingleState(state));
  }

  getAPYs() async {
    var response =
    await http.get("https://app.deus.finance/static-api.json");
    if (response.statusCode == 200) {
      final Map<String, dynamic> map = json.decode(response.body);
      state.stakeTokenObjects[0].apy = map['apy']['sand_dea'];
      state.stakeTokenObjects[1].apy = map['apy']['sand_deus'];
      state.stakeTokenObjects[2].apy = map['apy']['timetoken'];
      state.nativeBalancer.apy = map['apy']['bpt_native'];
      return true;
    }else{
      return false;
    }
  }
  getSDeaStakedValue() async {
    state.stakeTokenObjects[0].stakedAmount = await state.stakeService.getNumberOfStakedTokens(state.stakeTokenObjects[0].stakeToken.getTokenName());
    state.stakeTokenObjects[0].pendingReward = await state.stakeService.getNumberOfPendingRewardTokens(state.stakeTokenObjects[0].stakeToken.getTokenName());
  }
  getSDeusStakedValue() async {
    state.stakeTokenObjects[1].stakedAmount = await state.stakeService.getNumberOfStakedTokens(state.stakeTokenObjects[1].stakeToken.getTokenName());
    state.stakeTokenObjects[1].pendingReward = await state.stakeService.getNumberOfPendingRewardTokens(state.stakeTokenObjects[1].stakeToken.getTokenName());
  }
  getTimeTokenStakedValue() async {
    state.stakeTokenObjects[2].stakedAmount = await state.stakeService.getNumberOfStakedTokens(state.stakeTokenObjects[2].stakeToken.getTokenName());
    state.stakeTokenObjects[2].pendingReward = await state.stakeService.getNumberOfPendingRewardTokens(state.stakeTokenObjects[2].stakeToken.getTokenName());
  }

  getNativeBalancerStakedValue() async {
    state.nativeBalancer.stakedAmount = await state.stakeService.getNumberOfStakedTokens(state.nativeBalancer.stakeToken.getTokenName());
    state.nativeBalancer.pendingReward = await state.stakeService.getNumberOfPendingRewardTokens(state.nativeBalancer.stakeToken.getTokenName());
  }

  getData() async {
    await getAPYs();
    await getSDeaStakedValue();
    await getSDeusStakedValue();
    await getTimeTokenStakedValue();
    await getNativeBalancerStakedValue();
  }

  void changeSingleLiquidity(int i) {
    if(i==0)
      emit(StakingVaultOverviewSingleState(state));
    else
      emit(StakingVaultOverviewLiquidityState(state));
  }

  void claim(){

  }
}