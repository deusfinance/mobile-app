import 'dart:convert';

import 'package:convert/convert.dart';

import 'package:deus_mobile/core/util/responsive.dart';
import 'package:deus_mobile/core/widgets/selection_button.dart';
import 'package:deus_mobile/models/swap/GWei.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import '../../locator.dart';

enum Network{ETH, XDAI, HECO, BSC, MATIC}
enum ConfirmShowingMode { CONFIRM, BASIC_CUSTOMIZE, ADVANCED_CUSTOMIZE }
enum ShowingMode { LOADING, NONE }
enum GasFee { SLOW, AVERAGE, FAST, CUSTOM }

class ConfirmGasScreen extends StatefulWidget {
  static const route = '/confirm_gas';
  Transaction transaction;
  Network network;

  ConfirmGasScreen({required this.transaction, required this.network});

  @override
  _ConfirmGasScreenState createState() => _ConfirmGasScreenState();
}

class _ConfirmGasScreenState extends State<ConfirmGasScreen> {
  late ConfirmShowingMode confirmSwapShowingMode;
  late GWei? gWei;
  late bool showingError;
  late double? gasTokenPrice;
  late ShowingMode mode;
  late int estimatedGasNumber;
  late GasFee gasFee;
  TextEditingController nonceController = new TextEditingController();
  TextEditingController gasLimitController = new TextEditingController();
  TextEditingController gWeiController = new TextEditingController();

  Future<GWei?> getGWei() async {
    switch(widget.network){
      case Network.ETH:
        var response =
        await http.get(Uri.parse("https://www.gasnow.org/api/v3/gas/price?utm_source=:deusApp"));
        if (response.statusCode == 200) {
          var map = json.decode(response.body);
          GWei g = GWei.fromJson(map["data"]);
          return g;
        }
        return null;
      case Network.XDAI:
        GWei g = new GWei.init(1.0 * 1000000000, 1.0 * 1000000000, 1.0 * 1000000000);
        return g;
      case Network.HECO:
        GWei g = new GWei.init(1.0 * 1000000000, 1.0 * 1000000000, 1.0 * 1000000000);
        return g;
      case Network.BSC:
        GWei g = new GWei.init(10.0 * 1000000000, 10.0 * 1000000000, 10.0 * 1000000000);
        return g;
      case Network.MATIC:
        // TODO: Handle this case.
        break;
    }

  }

  Future<double?> getGasTokenPrice() async {
    switch(widget.network){
      case Network.ETH:
        var response = await http.get(
            Uri.parse("https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"));
        if (response.statusCode == 200) {
          var map = json.decode(response.body);
          return map['ethereum']['usd'];
        }
        return 0;
      case Network.XDAI:
        return 1;
      case Network.HECO:
        var response = await http.get(
            Uri.parse("https://api.coingecko.com/api/v3/simple/price?ids=huobi-token&vs_currencies=usd"));
        if (response.statusCode == 200) {
          var map = json.decode(response.body);
          return map['huobi-token']['usd'];
        }
        return 0;
      case Network.BSC:
        var response = await http.get(
            Uri.parse("https://api.coingecko.com/api/v3/simple/price?ids=binancecoin&vs_currencies=usd"));
        if (response.statusCode == 200) {
          var map = json.decode(response.body);
          return map['binancecoin']['usd'];
        }
        return 0;
      case Network.MATIC:
        // TODO: Handle this case.
        break;
    }

  }


  String getGasTokenName(){
    switch(widget.network){
      case Network.ETH:
        return "ETH";
      case Network.XDAI:
        return "XDAI";
      case Network.HECO:
        return "HT";
      case Network.BSC:
        return "BNB";
      case Network.MATIC:
        return "ETH";
    }
  }
  @override
  void initState() {
    super.initState();
    confirmSwapShowingMode = ConfirmShowingMode.CONFIRM;
    gasFee = GasFee.AVERAGE;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: mode == ShowingMode.LOADING
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        margin: EdgeInsets.fromLTRB(8.0, 8, 8.0, 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: MyStyles.darkWithBorderDecoration,
        child: confirmSwapShowingMode == ConfirmShowingMode.CONFIRM
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
                    confirmSwapShowingMode = ConfirmShowingMode.BASIC_CUSTOMIZE;
                  });
                },
                child: Text("EDIT",
                    style: TextStyle(
                        fontFamily: MyStyles.kFontFamily,
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
                "${getGasTokenName()} ${_computeGasFee().toStringAsFixed(6)}",
                style: MyStyles.whiteMediumTextStyle,
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Text("\$ ${(_computeGasFee() * gasTokenPrice!).toStringAsFixed(6)}",
                  style: MyStyles.lightWhiteSmallTextStyle)),
          const Divider(
            height: 15,
            thickness: 1,
            color: Colors.black,
          ),
          Visibility(
            visible: showingError == true,
            child: GestureDetector(
              onTap: (){
                getData();
              },
              child: Text("can not estimate gas fee. Tap this to try again",
                  style: TextStyle(
                    fontFamily: MyStyles.kFontFamily,
                    fontWeight: FontWeight.w300,
                    fontSize: MyStyles.S6,
                    color: MyColors.ToastRed,
                  )),
            ),
          ),
          SizedBox(
            height: 250,
          ),
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                    onTap: () {
                      locator<NavigationService>().goBack(context);
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
                            fontFamily: MyStyles.kFontFamily,
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
                        }else{
                          gas.gasLimit = estimatedGasNumber;
                        }
                        locator<NavigationService>().goBack(context, gas);
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
                          confirmSwapShowingMode = ConfirmShowingMode.BASIC_CUSTOMIZE;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              "BASIC",
                              style: confirmSwapShowingMode ==
                                  ConfirmShowingMode.BASIC_CUSTOMIZE
                                  ? TextStyle(
                                  fontFamily: MyStyles.kFontFamily,
                                  fontWeight: FontWeight.w300,
                                  fontSize: MyStyles.S6,
                                  foreground: Paint()
                                    ..shader = MyColors.greenToBlueGradient
                                        .createShader(
                                        Rect.fromLTRB(0, 0, 50, 30)))
                                  : MyStyles.lightWhiteSmallTextStyle,
                            ),
                            Visibility(
                              visible: confirmSwapShowingMode ==
                                  ConfirmShowingMode.BASIC_CUSTOMIZE,
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
                          confirmSwapShowingMode = ConfirmShowingMode.ADVANCED_CUSTOMIZE;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              "ADVANCED",
                              style: confirmSwapShowingMode ==
                                  ConfirmShowingMode.ADVANCED_CUSTOMIZE
                                  ? TextStyle(
                                  fontFamily: MyStyles.kFontFamily,
                                  fontWeight: FontWeight.w300,
                                  fontSize: MyStyles.S6,
                                  foreground: Paint()
                                    ..shader = MyColors.greenToBlueGradient
                                        .createShader(
                                        Rect.fromLTRB(0, 0, 50, 30)))
                                  : MyStyles.lightWhiteSmallTextStyle,
                            ),
                            Visibility(
                              visible: confirmSwapShowingMode ==
                                  ConfirmShowingMode.ADVANCED_CUSTOMIZE,
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
        confirmSwapShowingMode == ConfirmShowingMode.ADVANCED_CUSTOMIZE
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
                if (confirmSwapShowingMode == ConfirmShowingMode.ADVANCED_CUSTOMIZE) {
                  gasFee = GasFee.CUSTOM;
                }
                confirmSwapShowingMode = ConfirmShowingMode.CONFIRM;
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
              "${getGasTokenName()} ${_computeGasFee(gFee: GasFee.CUSTOM).toStringAsFixed(6)}",
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
                      "${getGasTokenName()} ${_computeGasFee(gFee: GasFee.SLOW).toStringAsFixed(6)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "\$ ${(_computeGasFee(gFee: GasFee.SLOW) * gasTokenPrice!).toStringAsFixed(6)}",
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
                      "${getGasTokenName()} ${(_computeGasFee(gFee: GasFee.AVERAGE)).toStringAsFixed(6)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "\$ ${(_computeGasFee(gFee: GasFee.AVERAGE) * gasTokenPrice!).toStringAsFixed(6)}",
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
                      "${getGasTokenName()} ${(_computeGasFee(gFee: GasFee.FAST)).toStringAsFixed(6)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "\$ ${(_computeGasFee(gFee: GasFee.FAST) * gasTokenPrice!).toStringAsFixed(6)}",
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
    setState(() {
      mode = ShowingMode.LOADING;
    });
    gWei = await getGWei();
    gasTokenPrice = await getGasTokenPrice();
    estimatedGasNumber = await estimateGas();

    if(estimatedGasNumber == 0 || gasTokenPrice == 0 || gWei == null){
      setState(() {
        showingError = true;
      });
    }else{
      setState(() {
        showingError = false;
      });
    }
    setState(() {
      mode = ShowingMode.NONE;
    });
  }

  double _computeGasFee({GasFee? gFee}) {
    if (gFee == null) {
      gFee = gasFee;
    }
    return estimatedGasNumber * _computeGasPrice(gFee: gFee) as double;
  }

  Future<int> estimateGas() async {
    switch(widget.network){
      case Network.ETH:
        Map<String, dynamic> map = new Map();
        map['from'] = widget.transaction.from.toString();
        map['to'] = widget.transaction.to.toString();
        if(widget.transaction.data != null) {
          var result = hex.encode(widget.transaction.data!);
          map['data'] = "0x$result";
        }
        if ( widget.transaction.value != null)
          map['value'] = widget.transaction.value!.getInWei.toInt();
        else
          map['value'] = 0;
        var response = await http.post(Uri.parse("https://app.deus.finance/app/mainnet/swap/estimate"), body: json.encode(map), headers: {"Content-Type": "application/json"});
        if (response.statusCode == 200) {
          var js = json.decode(response.body);
          return js['gas_fee'];
        }
        return 650000;
      case Network.XDAI:
        return 650000;
      case Network.HECO:
        return 650000;
      case Network.BSC:
        return 650000;
      case Network.MATIC:
        return 650000;
    }

  }

  _computeGasPrice({GasFee? gFee}) {
    if(gWei != null) {
      if (gFee == null) {
        gFee = gasFee;
      }
      if (gFee == GasFee.SLOW) {
        return 0.000000001 * gWei!.getSlow();
      } else if (gFee == GasFee.AVERAGE) {
        return 0.000000001 * gWei!.getAverage();
      } else if (gFee == GasFee.FAST) {
        return 0.000000001 * gWei!.getFast();
      } else if (gFee == GasFee.CUSTOM) {
        double gw = 0;
        if (gWeiController.text != "" &&
            double.tryParse(gWeiController.text) != null) {
          gw = double.tryParse(gWeiController.text)!;
        }
        return 0.000000001 * gw;
      }
    }else
      return 0;
  }
}
