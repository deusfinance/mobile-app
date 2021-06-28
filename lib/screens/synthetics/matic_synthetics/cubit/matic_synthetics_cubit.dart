

import 'package:deus_mobile/screens/synthetics/synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';


class MaticSyntheticsCubit extends SyntheticsCubit {
  MaticSyntheticsCubit() : super(SyntheticsChain.MATIC);

  bool isBuy() => state.fromToken.getTokenName() == "usdc";
}
