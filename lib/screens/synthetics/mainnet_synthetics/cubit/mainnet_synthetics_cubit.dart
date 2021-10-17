import '../../synthetics_cubit.dart';
import '../../synthetics_state.dart';

class MainnetSyntheticsCubit extends SyntheticsCubit {
  MainnetSyntheticsCubit() : super(SyntheticsChain.ETH);

  @override
  bool isBuy() => state.fromToken.getTokenName() == "dai";
}
