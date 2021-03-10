import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'stake_state.dart';

class StakeCubit extends Cubit<StakeState> {
  StakeCubit() : super(StakeHasToApprove(false));

  Future<void> approve() async {
    emit(StakePendingApproveDividedButton(true));
//TODO: Call approve function from backend/staking service.
    await Future.delayed(Duration(seconds: 1));
    emit(StakeIsApproved(true));
  }

  Future<void> stake() async {
    assert(state is StakeIsApproved || state is StakePendingApproveMergedButton);
    emit(StakePendingApproveMergedButton(true));
    // TODO: here comes the actual call to the stake service...
    await Future.delayed(Duration(seconds: 3));
    emit(StakeIsApproved(true));
  }

  void closeToast() {
    // state.showToast = false;
  }
}
