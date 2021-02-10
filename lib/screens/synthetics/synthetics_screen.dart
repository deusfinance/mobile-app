import 'package:deus/models/synthetic_model.dart';
import 'package:deus/models/transaction_status.dart';
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
                              backgroundColor: Colors.amber,
                            ),
                          ),
                          Text(
                            "DAI",
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
                            "select asset",
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
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        syntheticModel.type = SyntheticModel.LONG;
                      });
                    },
                    child: Container(
                      decoration: syntheticModel.type == SyntheticModel.LONG
                          ? MyStyles.blueToPurpleDecoration
                          : MyStyles.darkWithBorderDecoration,
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "LONG",
                          style: syntheticModel.type == SyntheticModel.LONG
                              ? MyStyles.WhiteMediumTextStyle
                              : MyStyles.lightWhiteMediumTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        syntheticModel.type = SyntheticModel.SHORT;
                      });
                    },
                    child: Container(
                      decoration: syntheticModel.type == SyntheticModel.SHORT
                          ? MyStyles.blueToPurpleDecoration
                          : MyStyles.darkWithBorderDecoration,
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "SHORT",
                          style: syntheticModel.type == SyntheticModel.SHORT
                              ? MyStyles.WhiteMediumTextStyle
                              : MyStyles.lightWhiteMediumTextStyle,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
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
                      "0.00 DAI per select asset",
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
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(16.0),
            decoration: MyStyles.blueToPurpleDecoration,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "MARKETS CLOSED",
                style: MyStyles.WhiteMediumTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
