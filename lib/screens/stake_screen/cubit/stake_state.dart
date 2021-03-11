part of 'stake_cubit.dart';

abstract class StakeState extends Equatable {
  const StakeState(this.showToast);

  final double apy = 99.93;
  final double balance = 13.234;

  final bool showToast;

  @override
  List<Object> get props => [showToast];
}

class StakeHasToApprove extends StakeState {
  StakeHasToApprove(bool showToast) : super(showToast);
}

class StakePendingApproveDividedButton extends StakeState {
  StakePendingApproveDividedButton(bool showToast) : super(showToast);
}

class StakeIsApproved extends StakeState {
  StakeIsApproved(bool showToast) : super(showToast);
}

class StakePendingApproveMergedButton extends StakeState {
  StakePendingApproveMergedButton(bool showToast) : super(showToast);
}
