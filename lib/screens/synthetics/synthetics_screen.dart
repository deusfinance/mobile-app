import 'package:deus/core/widgets/filled_gradient_selection_button.dart';
import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/core/widgets/svg.dart';
import 'package:deus/core/widgets/swap_field.dart';
import 'package:deus/data_source/currency_data.dart';
import 'package:deus/models/synthetic_model.dart';
import 'package:deus/screens/synthetics/market_timer.dart';
import 'package:deus/service/ethereum_service.dart';
import 'package:deus/service/stock_service.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

class SyntheticsScreen extends StatefulWidget {
  @override
  _SyntheticsScreenState createState() => _SyntheticsScreenState();
}

class _SyntheticsScreenState extends State<SyntheticsScreen> {
  SyntheticModel syntheticModel;
  StockService stockService;
  TextEditingController fromFieldController = new TextEditingController();
  TextEditingController toFieldController = new TextEditingController();
  bool isInProgress = false;

  @override
  void initState() {
    super.initState();
//    TODO chain id
    stockService = new StockService(
        ethService: new EthereumService(1), privateKey: "0x1321312");
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
    SwapField fromField = new SwapField(
        direction: Direction.from,
        initialToken: syntheticModel.from,
        page: TabPage.synthetics,
        controller: fromFieldController,
        tokenSelected: (selectedToken) {
          setState(() {
            syntheticModel.to = CurrencyData.dai;
            syntheticModel.from = selectedToken;
            if (syntheticModel.selectionMode == SelectionMode.none) {
              syntheticModel.selectionMode = SelectionMode.long;
            }
          });
        });
    fromFieldController.addListener(() {
      setState(() {
        syntheticModel.fromValue = double.parse(fromFieldController.text);
        syntheticModel.toValue = syntheticModel.fromValue * 1.023;
        toFieldController.text = syntheticModel.toValue.toString();
      });
    });
    SwapField toField = new SwapField(
      direction: Direction.to,
      controller: toFieldController,
      initialToken: syntheticModel.to,
      page: TabPage.synthetics,
      tokenSelected: (selectedToken) {
        setState(() {
          syntheticModel.to = selectedToken;
          syntheticModel.from = CurrencyData.dai;
          if (syntheticModel.selectionMode == SelectionMode.none) {
            syntheticModel.selectionMode = SelectionMode.long;
          }
        });
      },
    );
    toFieldController.addListener(() {
      setState(() {
        syntheticModel.toValue = double.parse(toFieldController.text);
      });
    });
    return Column(
      children: [
        const SizedBox(height: 30),
        fromField,
        const SizedBox(height: 12),
        GestureDetector(
            onTap: () {
              setState(() {
                var a = syntheticModel.from;
                syntheticModel.from = syntheticModel.to;
                syntheticModel.to = a;
              });
            },
            child: Center(
                child: PlatformSvg.asset('images/icons/arrow_down.svg'))),
        const SizedBox(height: 12),
        toField,
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
                  "0.0038 ${syntheticModel.from != null ? syntheticModel.from
                      .symbol : "asset name"} per ${syntheticModel.to != null
                      ? syntheticModel.to.symbol
                      : "asset name"}",
                  style: MyStyles.whiteSmallTextStyle,
                ),
                Container(
                  margin: EdgeInsets.only(left: 4.0),
                  child:
                  PlatformSvg.asset("images/icons/exchange.svg", width: 15),
                ),
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

        Opacity(opacity: isInProgress ? 0.5 : 1.0, child: _buildMainButton()),
      ],
    );
  }

  Widget _buildMainButton() {
    if (!stockService.checkWallet()) {
      return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.all(16.0),
        decoration: MyStyles.darkWithNoBorderDecoration,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "CONNECT WALLET",
            style: MyStyles.lightWhiteMediumTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (syntheticModel.syntheticState == SyntheticState.closedMarket) {
      return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.all(16.0),
        decoration: MyStyles.darkWithNoBorderDecoration,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "MARKETS ARE CLOSED",
            style: MyStyles.lightWhiteMediumTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (syntheticModel.to == null) {
      return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.all(16.0),
        decoration: MyStyles.darkWithNoBorderDecoration,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "SELECT ASSET",
            style: MyStyles.lightWhiteMediumTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (syntheticModel.fromValue == null || syntheticModel.fromValue == "") {
      return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.all(16.0),
        decoration: MyStyles.darkWithNoBorderDecoration,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "ENTER AN AMOUNT",
            style: MyStyles.lightWhiteMediumTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
//    TODO get balance
    if (syntheticModel.fromValue < 1) {
      return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.all(16.0),
        decoration: MyStyles.darkWithNoBorderDecoration,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "INSUFFICIENT BALANCE",
            style: MyStyles.lightWhiteMediumTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // TODO check approved
    return FilledGradientSelectionButton(
      label: syntheticModel.from == CurrencyData.dai ? 'Buy' : 'Sell',
      onPressed: () async {
        if (syntheticModel.from == CurrencyData.dai) {
          buy();
        } else {
          sell();
        }
        ;
      },
      gradient: MyColors.blueToPurpleGradient,
    );
//    return syntheticModel.syntheticState == SyntheticState.openMarket &&
//            syntheticModel.selectionMode != SelectionMode.none
//        //TODO (@CodingDavid8): Check for amount entered
//        ? FilledGradientSelectionButton(
//            label: syntheticModel.from == CurrencyData.dai ? 'Buy' : 'Sell',
//            onPressed: () {},
//            gradient: MyColors.blueToPurpleGradient,
//          )
//        : Container(
//            width: MediaQuery.of(context).size.width,
//            padding: EdgeInsets.all(16.0),
//            decoration: MyStyles.darkWithNoBorderDecoration,
//            child: Align(
//              alignment: Alignment.center,
//              child: Text(
//                syntheticModel.syntheticState == SyntheticState.closedMarket
//                    ? 'MARKETS ARE CLOSED'
//                    : syntheticModel.syntheticState ==
//                            SyntheticState.timeRequired
//                        ? 'YOU NEED TIME TOKENS'
//                        : 'ENTER AN AMOUNT',
//                style: MyStyles.lightWhiteMediumTextStyle,
//                textAlign: TextAlign.center,
//              ),
//            ),
//          );
  }

  Future approve() async {
    if (!isInProgress) {
      setState(() {
        isInProgress = true;
      });
      stockService.approve(syntheticModel.from.symbol.toLowerCase()).then((
          value) {
        setState(() {
          isInProgress = false;
        });
      });
    }
  }

  Future sell() async {
    if (!isInProgress) {
      setState(() {
        isInProgress = true;
      });
      stockService.sell(syntheticModel.from.symbol.toLowerCase(), "",null).then((
          value) {
        setState(() {
          isInProgress = false;
        });
      });
    }
  }

  Future buy() async {
    if (!isInProgress) {
      setState(() {
        isInProgress = true;
      });
      stockService.buy("", "", null).then((value) {
        setState(() {
          isInProgress = false;
        });
      });
    }
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
//          selected
//              ? syntheticModel.selectionMode = SelectionMode.none
//              : syntheticModel.selectionMode = SelectionMode.short;
          syntheticModel.selectionMode = SelectionMode.short;
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
//          selected
//              ? syntheticModel.selectionMode = SelectionMode.none
//              : syntheticModel.selectionMode = SelectionMode.long;
          syntheticModel.selectionMode = SelectionMode.long;
        });
      },
      selected: syntheticModel.selectionMode == SelectionMode.long,
      gradient: MyColors.blueToPurpleGradient,
    );
  }
}
