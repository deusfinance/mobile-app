import 'dart:convert';

import 'package:convert/convert.dart';
import '../../core/database/chain.dart';

import '../../core/util/responsive.dart';
import '../../core/widgets/selection_button.dart';
import '../../models/swap/gwei.dart';
import '../../models/swap/gas.dart';
import '../../routes/navigation_service.dart';
import '../../statics/my_colors.dart';
import '../../statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import '../../locator.dart';

enum ConfirmShowingMode { CONFIRM, BASIC_CUSTOMIZE, ADVANCED_CUSTOMIZE }
enum ShowingMode { LOADING, NONE }
enum GasFee { SLOW, AVERAGE, FAST, CUSTOM }

class ManageGasScreen extends StatefulWidget {
  static const route = '/confirm_gas';
  final Transaction transaction;
  final Chain chain;

  ManageGasScreen({required this.transaction, required this.chain});

  @override
  _ManageGasScreenState createState() => _ManageGasScreenState();
}

class _ManageGasScreenState extends State<ManageGasScreen> {
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
    switch (widget.chain.id) {
      case 1:
        final response = await http.get(Uri.parse(
            "https://www.gasnow.org/api/v3/gas/price?utm_source=:deusApp"));
        if (response.statusCode == 200) {
          final Map<String, dynamic> map = json.decode(response.body);
          final GWei gApi = GWei.fromJson(map["data"]);

          final double d =
              widget.transaction.gasPrice?.getInWei.toDouble() ?? 0;
          if (d > gApi.getFast() * 1000000000 + 10 * 1000000000) {
            final GWei g = new GWei.init(
                d + 10 * 1000000000, d + 10 * 1000000000, d + 10 * 1000000000);
            return g;
          } else {
            final GWei g = new GWei.init(
                gApi.getFast() * 1000000000 + 10 * 1000000000,
                gApi.getFast() * 1000000000 + 10 * 1000000000,
                gApi.getFast() * 1000000000 + 10 * 1000000000);
            return g;
          }
        }
        return null;
      case 100:
        final double d = widget.transaction.gasPrice?.getInWei.toDouble() ?? 0;
        if (d > 1.0 * 1000000000 * 2) {
          final GWei g = new GWei.init(d * 2, d * 2, d * 2);
          return g;
        } else {
          final GWei g = new GWei.init(
              1.0 * 1000000000 * 2, 1.0 * 1000000000 * 2, 1.0 * 1000000000 * 2);
          return g;
        }
      case 128:
        double gNumber = 2.0;
        final response = await http
            .get(Uri.parse("https://tc.hecochain.com/price/prediction"));
        if (response.statusCode == 200) {
          final Map<String, Map<String, dynamic>> map =
              json.decode(response.body);
          try {
            gNumber = map['prices']!['median'];
            // ignore: empty_catches
          } catch (e) {}
        }

        final double d = widget.transaction.gasPrice?.getInWei.toDouble() ?? 0;
        if (d > gNumber * 1000000000 * 2) {
          final GWei g = new GWei.init(d * 2, d * 2, d * 2);
          return g;
        } else {
          final GWei g = new GWei.init(gNumber * 1000000000 * 2,
              gNumber * 1000000000 * 2, gNumber * 1000000000 * 2);
          return g;
        }
      case 56:
        final double d = widget.transaction.gasPrice?.getInWei.toDouble() ?? 0;
        if (d > 5.0 * 1000000000 * 2) {
          final GWei g = new GWei.init(d * 2, d * 2, d * 2);
          return g;
        } else {
          final GWei g = new GWei.init(
              5.0 * 1000000000 * 2, 5.0 * 1000000000 * 2, 5.0 * 1000000000 * 2);
          return g;
        }
      case 137:
        // TODO: Handle this case.
        break;
      default:
        return null;
    }
  }

  Future<double?> getGasTokenPrice() async {
    switch (widget.chain.id) {
      case 1:
        final response = await http.get(Uri.parse(
            "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"));
        if (response.statusCode == 200) {
          final Map<String, Map<String, dynamic>> map =
              json.decode(response.body);
          return map['ethereum']!['usd'];
        }
        return 0;
      case 100:
        return 1;
      case 128:
        final response = await http.get(Uri.parse(
            "https://api.coingecko.com/api/v3/simple/price?ids=huobi-token&vs_currencies=usd"));
        if (response.statusCode == 200) {
          final Map<String, Map<String, dynamic>> map =
              json.decode(response.body);
          return map['huobi-token']!['usd'];
        }
        return 0;
      case 56:
        final response = await http.get(Uri.parse(
            "https://api.coingecko.com/api/v3/simple/price?ids=binancecoin&vs_currencies=usd"));
        if (response.statusCode == 200) {
          final Map<String, Map<String, dynamic>> map =
              json.decode(response.body);
          return map['binancecoin']!['usd'];
        }
        return 0;
      case 137:
        // TODO: Handle this case.
        break;
      default:
        return 0;
    }
  }

  String getGasTokenName() {
    return widget.chain.currencySymbol ?? "Native Coin";
  }

  @override
  void initState() {
    super.initState();
    confirmSwapShowingMode = ConfirmShowingMode.CONFIRM;
    gasFee = GasFee.FAST;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: mode == ShowingMode.LOADING
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: const EdgeInsets.fromLTRB(8.0, 8, 8.0, 8.0),
              padding: const EdgeInsets.all(12.0),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      locator<NavigationService>().goBack(context);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios_rounded),
                        const SizedBox(width: 8),
                        Text('BACK', style: MyStyles.whiteMediumTextStyle)
                      ],
                    ),
                  ),
                ),
                Text(
                  "CONFIRM FEES",
                  style: MyStyles.lightWhiteSmallTextStyle,
                ),
              ],
            ),
          ),
          const Divider(
            height: 25,
            thickness: 1,
            color: Colors.black,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
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
                              .createShader(const Rect.fromLTRB(0, 0, 20, 5)))),
              )),
          const SizedBox(
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
          const SizedBox(
            height: 8,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                  "\$ ${(_computeGasFee() * gasTokenPrice!).toStringAsFixed(6)}",
                  style: MyStyles.lightWhiteSmallTextStyle)),
          const Divider(
            height: 15,
            thickness: 1,
            color: Colors.black,
          ),
          Visibility(
            visible: showingError == true,
            child: InkWell(
              onTap: () {
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
          const SizedBox(
            height: 250,
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                margin: const EdgeInsets.all(8.0),
                child: SelectionButton(
                  label: 'CONFIRM',
                  onPressed: (bool selected) async {
                    final Gas gas = new Gas();
                    gas.gasPrice = _computeGasPrice();
                    if (gasFee == GasFee.CUSTOM) {
                      gas.nonce = int.tryParse(nonceController.text) ?? 0;
                      gas.gasLimit = int.tryParse(gasLimitController.text) ?? 0;
                    } else {
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
          margin: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                  InkWell(
                      onTap: () {
                        setState(() {
                          confirmSwapShowingMode =
                              ConfirmShowingMode.BASIC_CUSTOMIZE;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
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
                                            .createShader(const Rect.fromLTRB(
                                                0, 0, 50, 30)))
                                  : MyStyles.lightWhiteSmallTextStyle,
                            ),
                            Visibility(
                              visible: confirmSwapShowingMode ==
                                  ConfirmShowingMode.BASIC_CUSTOMIZE,
                              child: Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  height: 2.0,
                                  width: 40,
                                  decoration: MyStyles.greenToBlueDecoration),
                            )
                          ],
                        ),
                      )),
                  const SizedBox(
                    width: 12,
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          confirmSwapShowingMode =
                              ConfirmShowingMode.ADVANCED_CUSTOMIZE;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
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
                                            .createShader(const Rect.fromLTRB(
                                                0, 0, 50, 30)))
                                  : MyStyles.lightWhiteSmallTextStyle,
                            ),
                            Visibility(
                              visible: confirmSwapShowingMode ==
                                  ConfirmShowingMode.ADVANCED_CUSTOMIZE,
                              child: Container(
                                  margin: const EdgeInsets.only(top: 3),
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
        const SizedBox(
          height: 20,
        ),
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8.0),
          child: SelectionButton(
            label: 'SAVE',
            onPressed: (bool selected) {
              setState(() {
                if (confirmSwapShowingMode ==
                    ConfirmShowingMode.ADVANCED_CUSTOMIZE) {
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
      margin: const EdgeInsets.only(left: 8, right: 8),
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
          const SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "${getGasTokenName()} ${_computeGasFee(gFee: GasFee.CUSTOM).toStringAsFixed(6)}",
              style: MyStyles.whiteMediumTextStyle,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Gas Price (GWEI)",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
            ),
          ),
          const SizedBox(
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
                  FilteringTextInputFormatter.allow(
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
          const SizedBox(
            height: 8.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Gas Limit",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
            ),
          ),
          const SizedBox(
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
                  FilteringTextInputFormatter.allow(new RegExp(r'([0-9])'))
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
          const SizedBox(
            height: 8.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Nonce (optional)",
                style: MyStyles.lightWhiteSmallTextStyle,
              ),
            ),
          ),
          const SizedBox(
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
                  FilteringTextInputFormatter.allow(new RegExp(r'([0-9])'))
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
      margin: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Estimated Processing Times",
                style: MyStyles.lightWhiteMediumTextStyle,
              )),
          const SizedBox(
            height: 12.0,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select a higher gas fee to accelerate the processing of your transaction.*",
                style: MyStyles.lightWhiteSmallTextStyle,
              )),
          const SizedBox(
            height: 24.0,
          ),
          InkWell(
            onTap: () {
              setState(() {
                gasFee = GasFee.SLOW;
              });
            },
            child: Container(
              width: getScreenWidth(context),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
                color: gasFee == GasFee.SLOW ? MyColors.Black : MyColors.Gray,
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
                  const SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${getGasTokenName()} ${_computeGasFee(gFee: GasFee.SLOW).toStringAsFixed(6)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  const SizedBox(
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
          const SizedBox(
            height: 8.0,
          ),
          InkWell(
            onTap: () {
              setState(() {
                gasFee = GasFee.AVERAGE;
              });
            },
            child: Container(
              width: getScreenWidth(context),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
                color:
                    gasFee == GasFee.AVERAGE ? MyColors.Black : MyColors.Gray,
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
                  const SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${getGasTokenName()} ${(_computeGasFee(gFee: GasFee.AVERAGE)).toStringAsFixed(6)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  const SizedBox(
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
          const SizedBox(
            height: 8.0,
          ),
          InkWell(
            onTap: () {
              setState(() {
                gasFee = GasFee.FAST;
              });
            },
            child: Container(
              width: getScreenWidth(context),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
                color: gasFee == GasFee.FAST ? MyColors.Black : MyColors.Gray,
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
                  const SizedBox(
                    height: 6,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${getGasTokenName()} ${(_computeGasFee(gFee: GasFee.FAST)).toStringAsFixed(6)}",
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                  const SizedBox(
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

    if (estimatedGasNumber == 0 || gasTokenPrice == 0 || gWei == null) {
      setState(() {
        showingError = true;
      });
    } else {
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
    switch (widget.chain.id) {
      case 1:
        final Map<String, dynamic> map = new Map();
        map['from'] = widget.transaction.from.toString();
        map['to'] = widget.transaction.to.toString();
        if (widget.transaction.data != null) {
          final result = hex.encode(widget.transaction.data!);
          map['data'] = "0x$result";
        }
        if (widget.transaction.value != null)
          map['value'] = widget.transaction.value!.getInWei.toInt();
        else
          map['value'] = 0;
        final response = await http.post(
            Uri.parse("https://app.deus.finance/app/mainnet/swap/estimate"),
            body: json.encode(map),
            headers: {"Content-Type": "application/json"});
        if (response.statusCode == 200) {
          final Map<String, dynamic> js = json.decode(response.body);
          return js['gas_fee'];
        }
        return 650000;
      default:
        return 650000;
    }
  }

  _computeGasPrice({GasFee? gFee}) {
    if (gWei != null) {
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
    } else
      return 0;
  }
}
