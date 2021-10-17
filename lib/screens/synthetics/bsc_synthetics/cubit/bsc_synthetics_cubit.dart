import '../../synthetics_cubit.dart';
import '../../synthetics_state.dart';

class BscSyntheticsCubit extends SyntheticsCubit {
  BscSyntheticsCubit() : super(SyntheticsChain.BSC);

  // @override
  // Future<void> fromTokenChanged(Token selectedToken) async {
  //   state.toToken = CurrencyData.busd;
  //   state.fromToken = selectedToken;
  //   (state.fromToken as Stock).mode = Mode.LONG;
  //   state.fromFieldController.text = "";
  //   state.toFieldController.text = "";
  //   state.toValue = 0;
  //
  //   if (checkMarketClosed(selectedToken, Mode.LONG)) {
  //     state.marketClosed = true;
  //     emit(SyntheticsLoadingState(state));
  //     emit(SyntheticsAssetSelectedState(state,
  //         fromToken: selectedToken, mode: Mode.LONG));
  //   } else {
  //     state.marketClosed = false;
  //     emit(SyntheticsAssetSelectedState(state,
  //         fromToken: selectedToken, mode: Mode.LONG, isInProgress: true));
  //
  //     await getAllowances();
  //     (selectedToken as Stock).longBalance =
  //         await getTokenBalance(selectedToken);
  //     emit(SyntheticsAssetSelectedState(state,
  //         fromToken: selectedToken, isInProgress: false));
  //   }
  // }
  //
  // @override
  // Future<void> toTokenChanged(Token selectedToken) async {
  //   state.fromToken = CurrencyData.busd;
  //   state.toToken = selectedToken;
  //   (state.toToken as Stock).mode = Mode.LONG;
  //   state.fromFieldController.text = "";
  //   state.toFieldController.text = "";
  //   state.toValue = 0;
  //
  //   if (checkMarketClosed(selectedToken, Mode.LONG)) {
  //     state.marketClosed = true;
  //     emit(SyntheticsLoadingState(state));
  //     emit(SyntheticsAssetSelectedState(state,
  //         toToken: selectedToken, mode: Mode.LONG));
  //   } else {
  //     state.marketClosed = false;
  //     emit(SyntheticsLoadingState(state));
  //     emit(SyntheticsAssetSelectedState(state,
  //         toToken: selectedToken, mode: Mode.LONG, isInProgress: true));
  //
  //     await getAllowances();
  //     (selectedToken as Stock).longBalance =
  //         await getTokenBalance(selectedToken);
  //     emit(SyntheticsAssetSelectedState(state,
  //         toToken: selectedToken, isInProgress: false));
  //   }
  // }

  @override
  bool isBuy() => state.fromToken.getTokenName() == "busd";
}
