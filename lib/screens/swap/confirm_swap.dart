import 'dart:convert';

import 'package:deus/core/util/responsive.dart';
import 'package:deus/core/widgets/selection_button.dart';
import 'package:deus/models/GWei.dart';
import 'package:deus/models/gas.dart';
import 'package:deus/service/deus_swap_service.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

enum ConfirmSwapMode { CONFIRM, BASIC_CUSTOMIZE, ADVANCED_CUSTOMIZE }
enum Mode { LOADING, NONE, PROCESSING }
enum GasFee { SLOW, AVERAGE, FAST, CUSTOM }

class ConfirmSwapScreen extends StatefulWidget {
  static const route = '/confirm_swap';
  SwapService service;
  Transaction transaction;

  ConfirmSwapScreen({this.service, this.transaction});

  @override
  _ConfirmSwapScreenState createState() => _ConfirmSwapScreenState();
}

class _ConfirmSwapScreenState extends State<ConfirmSwapScreen> {
  ConfirmSwapMode confirmSwapMode;
  GWei gWei;
  double ethPrice;
  Mode mode;
  int estimatedGasNumber;
  GasFee gasFee;
  TextEditingController nonceController = new TextEditingController();
  TextEditingController gasLimitController = new TextEditingController();
  TextEditingController gWeiController = new TextEditingController();

  Future<bool> getGWei() async {
    var response =
        await http.get("https://ethgasstation.info/json/ethgasAPI.json");
    if (response.statusCode == 200) {
      var map = json.decode(response.body);
      gWei = GWei.fromJson(map);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getEthPrice() async {
    var response = await http.get(
        "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd");
    if (response.statusCode == 200) {
      var map = json.decode(response.body);
      ethPrice = map['ethereum']['usd'];
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    confirmSwapMode = ConfirmSwapMode.CONFIRM;
    mode = Mode.LOADING;
    gasFee = GasFee.AVERAGE;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: mode == Mode.LOADING
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: EdgeInsets.fromLTRB(8.0, 8, 8.0, 8.0),
              padding: EdgeInsets.all(12.0),
              decoration: MyStyles.darkWithBorderDecoration,
              child: confirmSwapMode == ConfirmSwapMode.CONFIRM
                  ? confirmScreen()
                  : customizeScreen(),
            ),
    );
  }

  Widget confirmScreen() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "CONFIRM FEES",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
            ),
          ),
          const Divider(
            height: 25,
            thickness: 1,
            color: Colors.black,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    confirmSwapMode = ConfirmSwapMode.BASIC_CUSTOMIZE;
                  });
                },
                child: Text("EDIT",
                    style: TextStyle(
                        fontFamily: "Monument",
                        fontWeight: FontWeight.w300,
                        fontSize: MyStyles.S5,
                        foreground: Paint()
                          ..shader = MyColors.greenToBlueGradient
                              .createShader(Rect.fromLTRB(0, 0, 20, 5)))),
              )),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "GAS FEE",
                  style: MyStyles.lightWhiteSmallTextStyle,
                ),
              ),
              Text(
                "ETH ${_computeGasFee()}",
                style: MyStyles.whiteMediumTextStyle,
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Text("\$ ${_computeGasFee() * ethPrice}",
                  style: MyStyles.lightWhiteSmallTextStyle)),
          const Divider(
            height: 15,
            thickness: 1,
            color: Colors.black,
          ),
          SizedBox(
            height: 250,
          ),
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Color(0xFFC4C4C4),
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "REJECT",
                      style: TextStyle(
                        fontFamily: "Monument",
                        fontWeight: FontWeight.w300,
                        fontSize: MyStyles.S4,
                        color: MyColors.HalfBlack,
                      ),
                    ),
                  ),
                ),
              )),
              Expanded(
                  child: Container(
                margin: EdgeInsets.all(8.0),
                child: SelectionButton(
                  label: 'CONFIRM',
                  onPressed: (bool selected) async {
                    Gas gas = new Gas();
                    gas.gasPrice = _computeGasPrice();
                    if (gasFee == GasFee.CUSTOM) {
                      gas.nonce = int.tryParse(nonceController.text) ?? 0;
                      gas.gasLimit = int.tryParse(gasLimitController.text) ?? 0;
                    }
                    Navigator.pop(context, gas);
                  },
                  selected: true,
                  gradient: MyColors.greenToBlueGradient,
                  textStyle: MyStyles.blackMediumTextStyle,
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }

  Widget customizeScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(left: 8.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CUSTOMIZE GAS",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          confirmSwapMode = ConfirmSwapMode.BASIC_CUSTOMIZE;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              "BASIC",
                              style: confirmSwapMode ==
                                      ConfirmSwapMode.BASIC_CUSTOMIZE
                                  ? TextStyle(
                                      fontFamily: "Monument",
                                      fontWeight: FontWeight.w300,
                                      fontSize: MyStyles.S6,
                                      foreground: Paint()
                                        ..shader = MyColors.greenToBlueGradient
                                            .createShader(
                                                Rect.fromLTRB(0, 0, 50, 30)))
                                  : MyStyles.lightWhiteSmallTextStyle,
                            ),
                            Visibility(
                              visible: confirmSwapMode ==
                                  ConfirmSwapMode.BASIC_CUSTOMIZE,
                              child: Container(
                                  margin: EdgeInsets.only(top: 3),
                                  height: 2.0,
                                  width: 40,
                                  decoration: MyStyles.greenToBlueDecoration),
                            )
                          ],
                        ),
                      )),
                  SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          confirmSwapMode = ConfirmSwapMode.ADVANCED_CUSTOMIZE;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              "ADVANCED",
                              style: confirmSwapMode ==
                                      ConfirmSwapMode.ADVANCED_CUSTOMIZE
                                  ? TextStyle(
                                      fontFamily: "Monument",
                                      fontWeight: FontWeight.w300,
                                      fontSize: MyStyles.S6,
                                      foreground: Paint()
                                        ..shader = MyColors.greenToBlueGradient
                                            .createShader(
                                                Rect.fromLTRB(0, 0, 50, 30)))
                                  : MyStyles.lightWhiteSmallTextStyle,
                            ),
                            Visibility(
                              visible: confirmSwapMode ==
                                  ConfirmSwapMode.ADVANCED_CUSTOMIZE,
                              child: Container(
                                  margin: EdgeInsets.only(top: 3),
                                  height: 2.0,
                                  width: 60,
                                  decoration: MyStyles.greenToBlueDecoration),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          height: 25,
          thickness: 1,
          color: Colors.black,
        ),
        confirmSwapMode == ConfirmSwapMode.ADVANCED_CUSTOMIZE
            ? advancedCustomize()
            : basicCustomize(),
        SizedBox(
          height: 20,
        ),
        Container(
          margin: EdgeInsets.only(left: 8, right: 8.0),
          child: SelectionButton(
            label: 'SAVE',
            onPressed: (bool selected) {
              setState(() {
                if (confirmSwapMode == ConfirmSwapMode.ADVANCED_CUSTOMIZE) {
                  gasFee = GasFee.CUSTOM;
                }
                confirmSwapMode = ConfirmSwapMode.CONFIRM;
              });
            },
            selected: true,
            gradient: MyColors.greenToBlueGradient,
            textStyle: MyStyles.blackMediumTextStyle,
          ),
        ),
      ],
    );
  }

  Widget advancedCustomize() {
    final textFieldBorder = OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10));

    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "New Transaction Fee",
              style: MyStyles.lightWhiteSmallTextStyle,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "ETH ${_computeGasFee(gFee: GasFee.CUSTOM)}",
              style: MyStyles.whiteMediumTextStyle,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 12.0),
              child: Text(
                "Gas Price (GWEI)",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          SizedBox(
            height: 55,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(17, 17, 17, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextField(
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Colors.white,
                inputFormatters: [
                  WhitelistingTextInputFormatter(
                      new RegExp(r'([0-9]+([.][0-9]*)?|[.][0-9]+)'))
                ],
                onChanged: (value) {
                  setState(() {});
                },
                controller: gWeiController,
                keyboardType: TextInputType.number,
                style: MyStyles.whiteSmallTextStyle,
                decoration: InputDecoration(
                    hintText: "0.0",
                    hintStyle: MyStyles.lightWhiteSmallTextStyle,
                    focusedBorder: textFieldBorder,
                    errorBorder: textFieldBorder,
                    enabledBorder: textFieldBorder,
                    disabledBorder: textFieldBorder,
                    focusedErrorBorder: textFieldBorder),
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 12.0),
              child: Text(
                "Gas Limit",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          SizedBox(
            height: 55,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(17, 17, 17, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextField(
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Colors.white,
                inputFormatters: [
                  WhitelistingTextInputFormatter(new RegExp(r'([0-9])'))
                ],
                controller: gasLimitController,
                keyboardType: TextInputType.number,
                style: MyStyles.whiteSmallTextStyle,
                decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: MyStyles.lightWhiteSmallTextStyle,
                    focusedBorder: textFieldBorder,
                    errorBorder: textFieldBorder,
                    enabledBorder: textFieldBorder,
                    disabledBorder: textFieldBorder,
                    focusedErrorBorder: textFieldBorder),
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 12.0),
              child: Text(
                "Nonce (optional)",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          SizedBox(
            height: 55,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(17, 17, 17, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextField(
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Colors.white,
                inputFormatters: [
                  WhitelistingTextInputFormatter(new RegExp(r'([0-9])'))
                ],
                controller: nonceController,
                keyboardType: TextInputType.number,
                style: MyStyles.whiteSmallTextStyle,
                decoration: InputDecoration(
                    focusedBorder: textFieldBorder,
                    errorBorder: textFieldBorder,
                    enabledBorder: textFieldBorder,
                    disabledBorder: textFieldBorder,
                    focusedErrorBorder: textFieldBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget basicCustomize() {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Estimated Processing Times",
                style: MyStyles.lightWhiteMediumTextStyle,
              )),
          SizedBox(
            height: 12.0,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select a higher gas fee to accelerate the processing of your transaction.*",
                style: MyStyles.lightWhiteSmallTextStyle,
              )),
          SizedBox(
            height: 24.0,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                gasFee = GasFee.SLOW;
              });
            },
            child: Container(
              width: getScreenWidth(context),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
                color: gasFee == GasFee.SLOW
                    ? MyColors.Black
                    : MyColors.Gray,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SLOW",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ETH ${_computeGasFee(gFee: GasFee.SLOW)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "\$ ${_computeGasFee(gFee: GasFee.SLOW) * ethPrice}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                gasFee = GasFee.AVERAGE;
              });
            },
            child: Container(
              width: getScreenWidth(context),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
                color: gasFee == GasFee.AVERAGE
                    ? MyColors.Black
                    : MyColors.Gray,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "AVERAGE",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ETH ${_computeGasFee(gFee: GasFee.AVERAGE)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "\$ ${_computeGasFee(gFee: GasFee.AVERAGE) * ethPrice}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                gasFee = GasFee.FAST;
              });
            },
            child: Container(
              width: getScreenWidth(context),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
                color: gasFee == GasFee.FAST
                    ? MyColors.Black
                    : MyColors.Gray,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "FAST",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ETH ${_computeGasFee(gFee: GasFee.FAST)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "\$ ${_computeGasFee(gFee: GasFee.FAST) * ethPrice}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getData() async {
    await getGWei();
    await getEthPrice();
//    TODO
    BigInt eg = await widget.service.ethService.estimateGas(widget.transaction);
    if(eg!=null)estimatedGasNumber = eg.toInt();
    else estimatedGasNumber = 100000;

    setState(() {
      mode = Mode.NONE;
    });
  }

  _computeGasFee({GasFee gFee}) {
    if (gFee == null) {
      gFee = gasFee;
    }
    return estimatedGasNumber * _computeGasPrice(gFee: gFee);
  }

  _computeGasPrice({GasFee gFee}) {
    if (gFee == null) {
      gFee = gasFee;
    }
    if (gFee == GasFee.SLOW) {
      return 0.000000001 * gWei.getSlow();
    } else if (gFee == GasFee.AVERAGE) {
      return 0.000000001 * gWei.getAverage();
    } else if (gFee == GasFee.FAST) {
      return 0.000000001 * gWei.getFast();
    } else if (gFee == GasFee.CUSTOM) {
      double gw = 0;
      if (gWeiController.text != "" &&
          double.tryParse(gWeiController.text) != null) {
        gw = double.tryParse(gWeiController.text);
      }
      return 0.000000001 * gw;
    }
  }
}
