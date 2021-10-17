import '../../synthetics_cubit.dart';
import '../../synthetics_state.dart';

class HecoSyntheticsCubit extends SyntheticsCubit {
  HecoSyntheticsCubit() : super(SyntheticsChain.HECO);

  @override
  bool isBuy() => state.fromToken.getTokenName() == "husd";
}
