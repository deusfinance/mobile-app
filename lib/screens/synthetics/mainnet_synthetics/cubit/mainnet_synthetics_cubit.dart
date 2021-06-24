
import 'package:deus_mobile/screens/synthetics/synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';


class MainnetSyntheticsCubit extends SyntheticsCubit {
  MainnetSyntheticsCubit() : super(SyntheticsChain.ETH);

  bool isBuy() => state.fromToken.getTokenName() == "dai";
}
