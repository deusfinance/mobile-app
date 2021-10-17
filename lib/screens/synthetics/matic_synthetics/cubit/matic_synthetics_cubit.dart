import '../../synthetics_cubit.dart';
import '../../synthetics_state.dart';

class MaticSyntheticsCubit extends SyntheticsCubit {
  MaticSyntheticsCubit() : super(SyntheticsChain.MATIC);

  @override
  bool isBuy() => state.fromToken.getTokenName() == "usdc";
}
