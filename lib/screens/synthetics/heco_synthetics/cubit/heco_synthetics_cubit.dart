

import 'package:deus_mobile/screens/synthetics/synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';


class HecoSyntheticsCubit extends SyntheticsCubit {
  HecoSyntheticsCubit() : super(SyntheticsChain.HECO);

  bool isBuy() => state.fromToken.getTokenName() == "husd";
}
