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
//    return Container(
//      decoration: BoxDecoration(color: Color(MyColors.Main_BG_Black)),
//      child: Column(
//        children: [
//          Container(
//            margin: EdgeInsets.fromLTRB(8.0, 24, 8, 4),
//            padding: EdgeInsets.all(12.0),
//            decoration: MyStyles.darkWithBorderDecoration,
//            child: Column(
//              children: [
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//                    Text(
//                      "from",
//                      style: MyStyles.lightWhiteSmallTextStyle,
//                    ),
//                    Text(
//                      "Balance: 123132",
//                      style: MyStyles.lightWhiteSmallTextStyle,
//                    ),
//                  ],
//                ),
//                Container(
//                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: [
//                      Text(
//                        "0.0",
//                        style: MyStyles.lightWhiteMediumTextStyle,
//                      ),
//                      Row(
//                        mainAxisSize: MainAxisSize.min,
//                        children: [
//                          Container(
//                            decoration: BoxDecoration(
//                                borderRadius: BorderRadius.circular(12.0),
//                                color: Color(MyColors.Cyan),
//                                border: Border.all(
//                                    color: Color(MyColors.White), width: 1.0)),
//                            padding: EdgeInsets.symmetric(
//                                horizontal: 8, vertical: 4),
//                            margin: EdgeInsets.only(right: 8.0),
//                            child: Text("MAX",
//                                style: MyStyles.whiteSmallTextStyle),
//                          ),
////                        circle avatar
//                          Container(
//                            margin: EdgeInsets.only(right: 8),
//                            child: CircleAvatar(
//                              radius: 15.0,
//                              backgroundColor: Colors.amber,
//                            ),
//                          ),
//                          Text(
//                            "DAI",
//                            style: MyStyles.WhiteMediumTextStyle,
//                          ),
//                          Icon(
//                            Icons.keyboard_arrow_down,
//                            color: Color(MyColors.White),
//                            size: 35.0,
//                          )
//                        ],
//                      ),
//                    ],
//                  ),
//                )
//              ],
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.all(12.0),
//            child: PlatformSvg.asset('images/icons/arrow_down.svg'),
//          ),
//          Container(
//            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//            padding: EdgeInsets.all(12.0),
//            decoration: MyStyles.darkWithBorderDecoration,
//            child: Column(
//              children: [
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//                    Text(
//                      "to",
//                      style: MyStyles.lightWhiteSmallTextStyle,
//                    ),
//                    Text(
//                      "Balance: 0",
//                      style: MyStyles.lightWhiteSmallTextStyle,
//                    ),
//                  ],
//                ),
//                Container(
//                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: [
//                      Text(
//                        "0.0",
//                        style: MyStyles.lightWhiteMediumTextStyle,
//                      ),
//                      Row(
//                        mainAxisSize: MainAxisSize.min,
//                        children: [
//                          Container(
//                            margin: EdgeInsets.only(right: 8),
//                            child: CircleAvatar(
//                              radius: 15.0,
//                              backgroundColor: Colors.white70,
//                            ),
//                          ),
//                          Text(
//                            "select asset",
//                            style: MyStyles.WhiteMediumTextStyle,
//                          ),
//                          Icon(
//                            Icons.keyboard_arrow_down,
//                            color: Color(MyColors.White),
//                            size: 35.0,
//                          )
//                        ],
//                      ),
//                    ],
//                  ),
//                )
//              ],
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.only(top: 16.0),
//            child: Row(
//              children: [
//                Expanded(
//                  child: GestureDetector(
//                    onTap: () {
//                      setState(() {
//                        syntheticModel.type = SyntheticModel.LONG;
//                      });
//                    },
//                    child: Container(
//                      decoration: syntheticModel.type == SyntheticModel.LONG
//                          ? MyStyles.blueToPurpleDecoration
//                          : MyStyles.darkWithBorderDecoration,
//                      margin: EdgeInsets.all(8.0),
//                      padding: EdgeInsets.all(16.0),
//                      child: Align(
//                        alignment: Alignment.center,
//                        child: Text(
//                          "LONG",
//                          style: syntheticModel.type == SyntheticModel.LONG
//                              ? MyStyles.WhiteMediumTextStyle
//                              : MyStyles.lightWhiteMediumTextStyle,
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//                Expanded(
//                  child: GestureDetector(
//                    onTap: () {
//                      setState(() {
//                        syntheticModel.type = SyntheticModel.SHORT;
//                      });
//                    },
//                    child: Container(
//                      decoration: syntheticModel.type == SyntheticModel.SHORT
//                          ? MyStyles.blueToPurpleDecoration
//                          : MyStyles.darkWithBorderDecoration,
//                      margin: EdgeInsets.all(8.0),
//                      padding: EdgeInsets.all(16.0),
//                      child: Align(
//                        alignment: Alignment.center,
//                        child: Text(
//                          "SHORT",
//                          style: syntheticModel.type == SyntheticModel.SHORT
//                              ? MyStyles.WhiteMediumTextStyle
//                              : MyStyles.lightWhiteMediumTextStyle,
//                        ),
//                      ),
//                    ),
//                  ),
//                )
//              ],
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: [
//                Text(
//                  "Price",
//                  style: MyStyles.lightWhiteSmallTextStyle,
//                ),
//                Row(
//                  children: [
//                    Text(
//                      "0.00 DAI per select asset",
//                      style: MyStyles.lightWhiteSmallTextStyle,
//                    ),
//                    Container(
//                      margin: EdgeInsets.only(left: 4.0),
//                      child: Image.asset(
//                        "assets/images/trade.png",
//                        height: 15.0,
//                        fit: BoxFit.cover,
//                      ),
//                    )
//                  ],
//                ),
//              ],
//            ),
//          ),
//          Container(
//            width: MediaQuery.of(context).size.width,
//            margin: EdgeInsets.all(8.0),
//            padding: EdgeInsets.all(16.0),
//            decoration: MyStyles.blueToPurpleDecoration,
//            child: Align(
//              alignment: Alignment.center,
//              child: Text(
//                "MARKETS CLOSED",
//                style: MyStyles.WhiteMediumTextStyle,
//              ),
//            ),
//          ),
//        ],
//      ),
//    );

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
