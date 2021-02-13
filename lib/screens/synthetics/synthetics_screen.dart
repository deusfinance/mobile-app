import 'package:deus/core/util/responsive.dart';
import 'package:deus/core/widgets/filled_gradient_selection_button.dart';
import 'package:deus/core/widgets/key_value_string.dart';
import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/core/widgets/svg.dart';
import 'package:deus/core/widgets/swap_field.dart';
import 'package:deus/data_source/currency_data.dart';
import 'package:deus/data_source/stock_data.dart';
import 'package:deus/models/crypto_currency.dart';
import 'package:deus/models/stock.dart';
import 'package:deus/models/synthetic_model.dart';
import 'package:deus/models/transaction_status.dart';
import 'package:deus/screens/synthetics/market_timer.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/statics.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

class SyntheticsScreen extends StatefulWidget {
  @override
  _SyntheticsScreenState createState() => _SyntheticsScreenState();
}

class _SyntheticsScreenState extends State<SyntheticsScreen> {
  SyntheticModel syntheticModel;

  @override
  void initState() {
    super.initState();
    syntheticModel = new SyntheticModel();
    syntheticModel.syntheticState = SyntheticState.openMarket;
  }

  @override
  Widget build(BuildContext context) {
    return syntheticModel.syntheticState != SyntheticState.loading
        ? _buildBody(context)
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MyStyles.mainPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildUserInput(context), _buildMarketTimer()],
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const SwapField(
            direction: Direction.from,
            balance: 999,
            initialToken: CurrencyData.eth),
        const SizedBox(height: 12),
        Center(child: PlatformSvg.asset('images/icons/arrow_down.svg')),
        const SizedBox(height: 12),
        SwapField<Stock>(
            direction: Direction.to, balance: 0, initialToken: null),
        const SizedBox(height: 18),
        _buildModeButtons(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Price",
              style: MyStyles.whiteSmallTextStyle,
            ),
            Row(
              children: [
                Text(
                  "0.0038 ETH per DEUS",
                  style: MyStyles.whiteSmallTextStyle,
                ),
                Container(
                  margin: EdgeInsets.only(left: 4.0),
                  child: PlatformSvg.asset("images/icons/exchange.svg", width: 15),
                )
              ],
            ),
          ],
        ),
//        KeyValueString('Price', '0.0038 ETH per DEUS ',
//            keyColor: MyColors.primary.withOpacity(0.75),
//            valueColor: MyColors.primary.withOpacity(0.75),
//            valueSuffix: PlatformSvg.asset('images/icons/exchange.svg',
//                height: 16, width: 16)),
        const SizedBox(
          height: 16,
        ),
        syntheticModel.syntheticState == SyntheticState.openMarket &&
                syntheticModel.selectionMode != SelectionMode.none
            //TODO (@CodingDavid8): Check for amount entered
            ? FilledGradientSelectionButton(
                label: syntheticModel.selectionMode == SelectionMode.long
                    ? 'Sync'
                    : 'Sync (Sell)',
                onPressed: () {},
                gradient: MyColors.blueToPurpleGradient,
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(16.0),
                decoration: MyStyles.darkWithNoBorderDecoration,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    syntheticModel.syntheticState == SyntheticState.closedMarket
                        ? 'MARKETS ARE CLOSED'
                        : syntheticModel.syntheticState ==
                                SyntheticState.timeRequired
                            ? 'YOU NEED TIME TOKENS'
                            : 'ENTER AN AMOUNT',
                    style: MyStyles.lightWhiteMediumTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
//        Padding(
//                padding: const EdgeInsets.symmetric(
//                    horizontal: MyStyles.mainPadding),
//                child: Container(
//                  padding: const EdgeInsets.symmetric(
//                    vertical: MyStyles.mainPadding,
//                  ),
//                  width: double.infinity,
//                  decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(10),
//                      color: const Color(0xFF242424)),
//                  child: Text(
//                    syntheticModel.syntheticState == SyntheticState.closedMarket
//                        ? 'MARKETS ARE CLOSED'
//                        : syntheticModel.syntheticState ==
//                                SyntheticState.timeRequired
//                            ? 'YOU NEED TIME TOKENS'
//                            : 'ENTER AN AMOUNT',
//                    style: MyStyles.lightWhiteMediumTextStyle,
//                    textAlign: TextAlign.center,
//                  ),
//                ),
//              )
      ],
    );
  }

  Container _buildModeButtons() {
    return Container(
      child: Row(children: [
        Expanded(child: _buildLongButton()),
        const SizedBox(width: 8),
        Expanded(child: _buildShortButton()),
      ]),
    );
  }

  Widget _buildMarketTimer() {
    return SizedBox(
//      width: getScreenWidth(context) - (SynchronizerScreen.kPadding * 2),
      child: MarketTimer(
        timerColor:
            //TODO: add colors to my_colors.dart (.red and .green)
            syntheticModel.syntheticState == SyntheticState.openMarket
                ? const Color(0xFF00D16C)
                : const Color(0xFFD40000),
        onEnd: () {
          setState(() {
            syntheticModel.syntheticState == SyntheticState.openMarket
                ? syntheticModel.syntheticState = SyntheticState.closedMarket
                : syntheticModel.syntheticState = SyntheticState.closedMarket;
          });
        },
        label: syntheticModel.syntheticState == SyntheticState.closedMarket
            ? 'UNTIL TRADING OPENS'
            : 'UNTIL TRADING CLOSES',
      ),
    );
  }

  Widget _buildShortButton() {
    return SelectionButton(
      label: 'SHORT',
      onPressed: (bool selected) {
        setState(() {
          selected
              ? syntheticModel.selectionMode = SelectionMode.none
              : syntheticModel.selectionMode = SelectionMode.short;
        });
      },
      selected: syntheticModel.selectionMode == SelectionMode.short,
      gradient: MyColors.blueToPurpleGradient,
    );
  }

  Widget _buildLongButton() {
    return SelectionButton(
      label: 'LONG',
      onPressed: (bool selected) {
        setState(() {
          selected
              ? syntheticModel.selectionMode = SelectionMode.none
              : syntheticModel.selectionMode = SelectionMode.long;
        });
      },
      selected: syntheticModel.selectionMode == SelectionMode.long,
      gradient: MyColors.blueToPurpleGradient,
    );
  }
}
