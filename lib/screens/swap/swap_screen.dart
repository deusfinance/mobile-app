import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/core/widgets/svg.dart';
import 'package:deus/core/widgets/swap_field.dart';
import 'package:deus/data_source/currency_data.dart';
import 'package:deus/models/stock.dart';
import 'package:deus/models/swap_model.dart';
import 'package:deus/service/deus_swap_service.dart';
import 'package:deus/service/ethereum_service.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SwapScreen extends StatefulWidget {
  static const route = "/swap";

  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  SwapModel swapModel = SwapModel(CurrencyData.eth, CurrencyData.deus);
  TextEditingController fromFieldController = new TextEditingController();
  TextEditingController toFieldController = new TextEditingController();
  TextEditingController slippageController = new TextEditingController();
  bool isInProgress = false;
  DeusSwapService swapService;

  @override
  void initState() {
    super.initState();
    swapService = new DeusSwapService(
        ethService: new EthereumService(1), privateKey: "0x312");
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    SwapField fromField = new SwapField(
      direction: Direction.from,
      balance: 999,
      initialToken: swapModel.from,
      controller: fromFieldController,
      tokenSelected: (selectedToken) {
        setState(() {
          swapModel.from = selectedToken;
          setState(() {
            swapModel.approved = false;
          });
          getAllowances();
//         TODO get balance
        });
      },
    );
    fromFieldController.addListener(() {
      setState(() {
        swapModel.fromValue = double.parse(fromFieldController.text);
        swapModel.toValue = swapModel.fromValue * 1.023;
        toFieldController.text = swapModel.toValue.toString();
      });
    });

    SwapField toField = new SwapField(
      direction: Direction.to,
      balance: 0,
      initialToken: swapModel.to,
      controller: toFieldController,
      tokenSelected: (selectedToken) {
        setState(() {
          swapModel.to = selectedToken;
        });
      },
    );
    toFieldController.addListener(() {
      setState(() {
        swapModel.toValue = double.parse(toFieldController.text);
      });
    });
    return Container(
      padding: EdgeInsets.all(MyStyles.mainPadding),
      decoration: BoxDecoration(color: Color(MyColors.Main_BG_Black)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            fromField,
            const SizedBox(height: 12),
            GestureDetector(
                onTap: (){
                  setState(() {
                    var a = swapModel.from;
                    swapModel.from = swapModel.to;
                    swapModel.to = a;
                  });
                },
                child: Center(child: PlatformSvg.asset('images/icons/arrow_down.svg'))),
            const SizedBox(height: 12),
            toField,
            const SizedBox(height: 18),
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
                      "0.0038 ${swapModel.from != null ? swapModel.from.symbol : "asset name"} per ${swapModel.to != null ? swapModel.to.symbol : "asset name"}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 4.0),
                        child: PlatformSvg.asset("images/icons/exchange.svg",
                            width: 15),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Price Impact",
                  style: MyStyles.whiteSmallTextStyle,
                ),
                Text(
                  "+ 0.23%",
                  style: MyStyles.whiteSmallTextStyle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Slippage Tolerance",
                style: MyStyles.whiteSmallTextStyle,
              ),
            ),
            const SizedBox(height: 8),
            _buildSlippageButtons(),
            const SizedBox(height: 12),
            _buildModeButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButtons() {
    if (!swapService.checkWallet()) {
      return Container(
        width: MediaQuery.of(context).size.width,
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
    return Opacity(
      opacity: isInProgress ? 0.5 : 1,
      child: Container(
        child: Row(children: [
          Visibility(
            visible: !swapModel.approved,
            child: Expanded(
              child: _buildApproveButton(),
            ),
          ),
          Visibility(
              visible: !swapModel.approved,
              child: SizedBox(
                width: 8.0,
              )),
          Expanded(
            child: _buildSwapButton(),
          )
        ]),
      ),
    );
  }

  Widget _buildApproveButton() {
    return SelectionButton(
      label: 'Approve',
      onPressed: (bool selected) {
//        TODO approve it
        approve();
      },
      selected: true,
      gradient: MyColors.greenToBlueGradient,
      textStyle: MyStyles.blackMediumTextStyle,
    );
  }

  Widget _buildSwapButton() {
//    TODO get balance
    if(swapModel.approved && swapModel.fromValue<1.0){
      return Container(
        width: MediaQuery.of(context).size.width,
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
    return SelectionButton(
      label: 'Swap',
      onPressed: (bool selected) {
        swapTokens();
      },
      selected: swapModel.approved,
      gradient: MyColors.greenToBlueGradient,
      textStyle: MyStyles.blackMediumTextStyle,
    );
  }

  Widget _buildSlippageButtons() {
    return Row(children: [
      Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () {
            setState(() {
              swapModel.slippage = 0.1;
            });
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.all(4.0),
            decoration: swapModel.slippage == 0.1
                ? MyStyles.greenToBlueDecoration
                : MyStyles.lightBlackBorderDecoration,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "0.1%",
                style: swapModel.slippage == 0.1
                    ? MyStyles.blackSmallTextStyle
                    : MyStyles.whiteSmallTextStyle,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () {
            setState(() {
              swapModel.slippage = 0.5;
            });
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.all(4.0),
            decoration: swapModel.slippage == 0.5
                ? MyStyles.greenToBlueDecoration
                : MyStyles.lightBlackBorderDecoration,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "0.5%",
                style: swapModel.slippage == 0.5
                    ? MyStyles.blackSmallTextStyle
                    : MyStyles.whiteSmallTextStyle,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () {
            setState(() {
              swapModel.slippage = 1.0;
            });
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.all(4.0),
            decoration: swapModel.slippage == 1.0
                ? MyStyles.greenToBlueDecoration
                : MyStyles.lightBlackBorderDecoration,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "1%",
                style: swapModel.slippage == 1.0
                    ? MyStyles.blackSmallTextStyle
                    : MyStyles.whiteSmallTextStyle,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: 5,
        child: GestureDetector(
          onTap: () {
            setState(() {
              swapModel.slippage = 2.0;
            });
          },
//                    TODO slippage handling
          child: Container(
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.all(4.0),
            decoration: swapModel.slippage > (1.0)
                ? MyStyles.greenToBlueDecoration
                : MyStyles.lightBlackBorderDecoration,
            child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        maxLines: 1,
                        controller: slippageController,
                        style: swapModel.slippage > (1.0)
                            ? MyStyles.blackSmallTextStyle
                            : MyStyles.whiteSmallTextStyle,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        ),
                      ),
                    ),
                    Text(
                      "%",
                      style: swapModel.slippage > (1.0)
                          ? MyStyles.blackSmallTextStyle
                          : MyStyles.whiteSmallTextStyle,
                    ),
                  ],
                )),
          ),
        ),
      ),
    ]);
  }

  Future approve() async {
    if (!isInProgress) {
      setState(() {
        isInProgress = true;
      });
      swapService.approve(swapModel.from.symbol).then((value) {
        setState(() {
//          TODO handle result
          isInProgress = false;
          swapModel.approved = true;
        });
      });
    }
  }

  Future getAllowances() async {
    setState(() {
      isInProgress = true;
    });
    swapService.getAllowances(swapModel.from.symbol).then((value) {
      setState(() {
        isInProgress = false;
      });
      if(double.parse(value)>double.parse(fromFieldController.text)){
        setState(() {
          swapModel.approved = true;
        });
      }
    });
  }

  Future swapTokens() async {
    if (!isInProgress && swapModel.approved) {
      setState(() {
        isInProgress = true;
      });
      swapService
          .swapTokens(swapModel.from, swapModel.to, swapModel.fromValue)
          .then((value) {
        setState(() {
//          TODO handle result and show toast and ...
          isInProgress = false;
        });
      });
    }
  }
}
