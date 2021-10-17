import '../../synthetics_cubit.dart';
import '../../synthetics_state.dart';

class XDaiSyntheticsCubit extends SyntheticsCubit {
  XDaiSyntheticsCubit() : super(SyntheticsChain.XDAI);

  @override
  bool isBuy() => state.fromToken.getTokenName() == "xdai";
}
