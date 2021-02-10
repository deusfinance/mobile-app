import 'package:deus/models/swap_model.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
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
    return Container(
      decoration: BoxDecoration(color: Color(MyColors.Main_BG_Black)),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(8.0, 24, 8, 4),
            padding: EdgeInsets.all(12.0),
            decoration: MyStyles.darkWithBorderDecoration,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "from",
                      style: MyStyles.lightWhiteSmallTextStyle,
                    ),
                    Text(
                      "Balance: 123132",
                      style: MyStyles.lightWhiteSmallTextStyle,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "0.0",
                        style: MyStyles.lightWhiteMediumTextStyle,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Color(MyColors.Cyan),
                                border: Border.all(
                                    color: Color(MyColors.White), width: 1.0)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            margin: EdgeInsets.only(right: 8.0),
                            child: Text("MAX",
                                style: MyStyles.whiteSmallTextStyle),
                          ),
//                        circle avatar
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 15.0,
                              backgroundColor: Colors.white70,
                            ),
                          ),
                          Text(
                            "ETH",
                            style: MyStyles.WhiteMediumTextStyle,
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(MyColors.White),
                            size: 35.0,
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(Icons.arrow_downward,
                color: Color(MyColors.White), size: 30.0),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: EdgeInsets.all(12.0),
            decoration: MyStyles.darkWithBorderDecoration,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "to",
                      style: MyStyles.lightWhiteSmallTextStyle,
                    ),
                    Text(
                      "Balance: 0",
                      style: MyStyles.lightWhiteSmallTextStyle,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "0.0",
                        style: MyStyles.lightWhiteMediumTextStyle,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 15.0,
                              backgroundColor: Colors.white70,
                            ),
                          ),
                          Text(
                            "DEUS",
                            style: MyStyles.WhiteMediumTextStyle,
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(MyColors.White),
                            size: 35.0,
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Price",
                  style: MyStyles.lightWhiteSmallTextStyle,
                ),
                Row(
                  children: [
                    Text(
                      "123.23 DEUS per ETH",
                      style: MyStyles.lightWhiteSmallTextStyle,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 4.0),
                      child: Image.asset(
                        "assets/images/trade.png",
                        height: 15.0,
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Price Impact",
                  style: MyStyles.lightWhiteSmallTextStyle,
                ),
                Text(
                  "+ 0.23%",
                  style: MyStyles.lightWhiteSmallTextStyle,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Slippage Tolerance",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: Row(children: [
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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 0),
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
              ])),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Visibility(
                  visible: !swapModel.approved,
                  child: Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          swapModel.approved = true;
                        });
                      },
                      child: Container(
                        decoration: MyStyles.greenToBlueDecoration,
                        margin: EdgeInsets.all(8.0),
                        padding: EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "APPROVE",
                            style: MyStyles.blackMediumTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: swapModel.approved
                          ? MyStyles.greenToBlueDecoration
                          : MyStyles.darkWithBorderDecoration,
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "SWAP",
                          style: swapModel.approved
                              ? MyStyles.blackMediumTextStyle
                              : MyStyles.lightWhiteMediumTextStyle,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
