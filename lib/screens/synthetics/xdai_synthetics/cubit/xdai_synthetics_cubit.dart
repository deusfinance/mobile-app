
import 'package:deus_mobile/screens/synthetics/synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';


class XDaiSyntheticsCubit extends SyntheticsCubit {
  XDaiSyntheticsCubit() : super(SyntheticsChain.XDAI);

  bool isBuy() => state.fromToken.getTokenName() == "xdai";
}
