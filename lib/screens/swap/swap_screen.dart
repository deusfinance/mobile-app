import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/core/widgets/svg.dart';
import 'package:deus/core/widgets/swap_field.dart';
import 'package:deus/data_source/currency_data.dart';
import 'package:deus/models/stock.dart';
import 'package:deus/models/swap_model.dart';
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
  SwapModel swapModel = SwapModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MyStyles.mainPadding),
      decoration: BoxDecoration(color: Color(MyColors.Main_BG_Black)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const SwapField(
                direction: Direction.from,
                balance: 999,
                initialToken: CurrencyData.eth),
            const SizedBox(height: 12),
            Center(child: PlatformSvg.asset('images/icons/arrow_down.svg')),
            const SizedBox(height: 12),
            SwapField(
                direction: Direction.to,
                balance: 0,
                initialToken: CurrencyData.eth),
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
                      "123.23 DEUS per ETH",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 4.0),
                      child: PlatformSvg.asset("images/icons/exchange.svg",
                          width: 15),
                    )
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
    return Container(
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
    );
  }

  Widget _buildApproveButton() {
    return SelectionButton(
      label: 'Approve',
      onPressed: (bool selected) {
//        TODO approve it
        setState(() {
          swapModel.approved = true;
        });
      },
      selected: true,
      gradient: MyColors.greenToBlueGradient,
      textStyle: MyStyles.blackMediumTextStyle,
    );
  }

  Widget _buildSwapButton() {
    return SelectionButton(
      label: 'Swap',
      onPressed: (bool selected) {
//        TODO
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
            decoration: swapModel.slippage > 1.0
                ? MyStyles.greenToBlueDecoration
                : MyStyles.lightBlackBorderDecoration,
            child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: swapModel.slippage > 1.0
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
                      style: swapModel.slippage > 1.0
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
}
