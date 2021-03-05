import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';

import '../../core/widgets/selection_button.dart';
import '../../core/widgets/svg.dart';
import '../../core/widgets/swap_field.dart';
import '../../core/widgets/toast.dart';
import '../../data_source/currency_data.dart';
import '../../models/gas.dart';
import '../../models/swap_model.dart';
import '../../models/token.dart';
import '../../models/transaction_status.dart';
import '../../service/deus_swap_service.dart';
import '../../service/ethereum_service.dart';
import '../../statics/my_colors.dart';
import '../../statics/statics.dart';
import '../../statics/styles.dart';
import 'confirm_swap.dart';

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
  StreamController<String> streamController = StreamController();
  bool isInProgress = false;
  bool fetchingData = true;
  SwapService swapService;
  double priceImpact = 0;
  List<Token> route = [];
  bool isPriceRatioForward = true;
  bool showingToast = false;
  String toastMessage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    swapService = new SwapService(
        ethService: new EthereumService(4),
        privateKey:
            "0x394b2559d9e727734001346346e311d3bba6a0a2d566d8cb79647c755e41355d");
    fetchBalances();
    streamController.stream
        .transform(debounce(Duration(milliseconds: 500)))
        .listen((s) async {
      if (double.tryParse(s) != null && double.tryParse(s) > 0) {
        swapService
            .getAmountsOut(
                swapModel.from.getTokenName(), swapModel.to.getTokenName(), s)
            .then((value) {
          setState(() {
            toFieldController.text = EthereumService.formatDouble(value);
          });
          computePriceImpact(fromFieldController.text, toFieldController.text);
        });
      } else {
        setState(() {
          toFieldController.text = "0.0";
        });
        computePriceImpact(fromFieldController.text, toFieldController.text);
      }
    });
  }

  fetchBalances() async {
    swapModel.from.balance =
        await swapService.getTokenBalance(swapModel.from.getTokenName());
    swapModel.to.balance =
        await swapService.getTokenBalance(swapModel.to.getTokenName());
    await getAllowances();
    setState(() {
      fetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return fetchingData
        ? Center(
            child: CircularProgressIndicator(),
          )
        : _buildBody(context);
  }

  Future<Gas> showConfirmGasFeeDialog(Transaction transaction) async {
    Gas res = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
          alignment: Alignment.center,
          child: ConfirmSwapScreen(
            service: swapService,
            transaction: transaction,
          )),
      barrierDismissible: true,
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          child: child,
          opacity: anim1,
        ),
      ),
      transitionDuration: Duration(milliseconds: 10),
    );
    return res;
  }

  Widget _buildTransactionPending() {
    return Container(
      margin: EdgeInsets.only(left:16, right: 16),
      child: Toast(
        label: 'Transaction Pending',
        message: toastMessage,
        color: MyColors.ToastGrey,
        onPressed: () {},
        onClosed: () {
          setState(() {
            showingToast = false;
          });
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    SwapField fromField = new SwapField(
      direction: Direction.from,
      initialToken: swapModel.from,
      controller: fromFieldController,
      tokenSelected: (selectedToken) async {
        setState(() {
          swapModel.from = selectedToken;
          if (swapModel.to.getTokenName() == swapModel.from.getTokenName()) {
            if (swapModel.from.getTokenName() == "eth") {
              swapModel.to = CurrencyData.deus;
            } else {
              swapModel.to = CurrencyData.eth;
            }
          }
          fromFieldController.text = "";
          toFieldController.text = "";
          route = [];
        });
        await getAllowances();
        getTokenBalance(swapModel.from);
      },
    );
    if (!fromFieldController.hasListeners) {
      fromFieldController.addListener(() {
        listenInput();
      });
    }

    SwapField toField = new SwapField(
      direction: Direction.to,
      initialToken: swapModel.to,
      controller: toFieldController,
      tokenSelected: (selectedToken) async {
        setState(() {
          swapModel.to = selectedToken;
          if (swapModel.to.getTokenName() == swapModel.from.getTokenName()) {
            if (swapModel.to.getTokenName() == "eth") {
              swapModel.from = CurrencyData.deus;
            } else {
              swapModel.from = CurrencyData.eth;
            }
          }
          fromFieldController.text = "";
          toFieldController.text = "";
          route = [];
        });
        getTokenBalance(swapModel.to);
      },
    );
    return Container(
      padding: EdgeInsets.all(MyStyles.mainPadding),
      decoration: BoxDecoration(color: MyColors.Main_BG_Black),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                fromField,
                const SizedBox(height: 12),
                GestureDetector(
                    onTap: () async {
                      setState(() {
                        Token a = swapModel.from;
                        swapModel.from = swapModel.to;
                        swapModel.to = a;
                        fromFieldController.text = "";
                        toFieldController.text = "";
                        route = new List.from(route.reversed);
                      });
                      getAllowances();
                    },
                    child: Center(
                        child:
                            PlatformSvg.asset('images/icons/arrow_down.svg'))),
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
                          isPriceRatioForward
                              ? "${_getPriceRatio()} ${swapModel.from != null ? swapModel.from.symbol : "asset name"} per ${swapModel.to != null ? swapModel.to.symbol : "asset name"}"
                              : "${_getPriceRatio()} ${swapModel.to != null ? swapModel.to.symbol : "asset name"} per ${swapModel.from != null ? swapModel.from.symbol : "asset name"}",
                          style: MyStyles.whiteSmallTextStyle,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isPriceRatioForward = !isPriceRatioForward;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 4.0),
                            child: PlatformSvg.asset(
                                "images/icons/exchange.svg",
                                width: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPriceImpact(),
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Route",
                    style: MyStyles.whiteSmallTextStyle,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRouteWidget(),
              ],
            ),
          ),
          showingToast
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildTransactionPending())
              : Container(),
        ],
      ),
    );
  }

  String _getPriceRatio() {
    double a = double.tryParse(fromFieldController.text) ?? 0;
    double b = double.tryParse(toFieldController.text) ?? 0;
    if (a != 0 && b != 0) {
      if (isPriceRatioForward)
        return EthereumService.formatDouble((a / b).toString(), 5);
      return EthereumService.formatDouble((b / a).toString(), 5);
    }
    return "0.0";
  }

  Widget _buildPriceImpact() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Price Impact",
          style: MyStyles.whiteSmallTextStyle,
        ),
        Text(
          "${priceImpact == 0 ? "0.0" : priceImpact < 0.005 ? "<0.005" : priceImpact}%",
          style: TextStyle(
            fontFamily: "Monument",
            fontWeight: FontWeight.w300,
            fontSize: MyStyles.S6,
            color: priceImpact <= 1
                ? Color(0xFF00D16C)
                : (priceImpact <= 3
                    ? Color(0xFFFFFFFF)
                    : (priceImpact < 5
                        ? Color(0xFFf58516)
                        : Color(0xFFD40000))),
          ),
        ),
      ],
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
            visible: !swapModel.approved &&
                fromFieldController.text != "" &&
                double.tryParse(fromFieldController.text) != null &&
                double.tryParse(fromFieldController.text) != 0,
            child: Expanded(
              child: _buildApproveButton(),
            ),
          ),
          Visibility(
              visible: !swapModel.approved &&
                  fromFieldController.text != "" &&
                  double.tryParse(fromFieldController.text) != null &&
                  double.tryParse(fromFieldController.text) != 0,
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
        approve();
      },
      selected: true,
      gradient: MyColors.greenToBlueGradient,
      textStyle: MyStyles.blackMediumTextStyle,
    );
  }

  Widget _buildRouteWidget() {
    if (route.length == 0) {
      swapService
          .getPath(swapModel.from.getTokenName(), swapModel.to.getTokenName())
          .then((value) {
        value.forEach((addr) {
          route.add(EthereumService.addressToTokenMap[addr.toLowerCase()]);
        });
        setState(() {});
      });
    }
    return Container(
        margin: EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 30,
            child: ListView.builder(
                itemCount: route.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  Token token = route[index];
                  return SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        token.logoPath.showCircleImage(radius: 10),
                        const SizedBox(width: 5),
                        Text(token.symbol, style: MyStyles.whiteSmallTextStyle),
                        (index < route.length - 1)
                            ? _buildRouteTransformWidget(route, index)
                            : Container(),
                      ],
                    ),
                  );
                }),
          ),
        ));
  }

  Widget _buildRouteTransformWidget(List<Token> route, int index) {
    if ((route[index].getTokenName() == "eth" &&
            route[index + 1].getTokenName() == "deus") ||
        (route[index].getTokenName() == "deus" &&
            route[index + 1].getTokenName() == "eth")) {
      return Row(
        children: [
          const SizedBox(width: 15),
          Image(
            width: 15,
            height: 15,
            image: Svg('assets/images/icons/d-swap.svg'),
          ),
          const SizedBox(width: 5),
          Image(
            width: 15,
            height: 15,
            image: Svg('assets/images/icons/right-arrow.svg'),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const SizedBox(width: 15),
          Image.asset(
            'assets/images/icons/uni.png',
            width: 15,
            height: 15,
          ),
//        CircleAvatar(radius: 10, backgroundImage: provider.Svg('assets/images/icons/uni.svg')),
          const SizedBox(width: 5),
          Image(
            width: 15,
            height: 15,
            image: Svg('assets/images/icons/right-arrow.svg'),
          ),
        ],
      );
    }
  }

  Widget _buildSwapButton() {
    if (fromFieldController.text == "" || (double.tryParse(fromFieldController.text) != null && double.tryParse(fromFieldController.text) == 0)) {
      return Container(
        width: MediaQuery.of(context).size.width,
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
    if (swapModel.approved &&
        swapModel.from.getBalance() <
            EthereumService.getWei(fromFieldController.text)) {
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
    if (!slippageController.hasListeners) {
      slippageController.addListener(() {
        setState(() {
          try {
            swapModel.slippage = double.parse(slippageController.text);
          } on Exception catch (value) {
            swapModel.slippage = 0.5;
          }
        });
      });
    }
    return Row(children: [
      Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () {
            setState(() {
              swapModel.slippage = 0.1;
              slippageController.text = "";
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
              slippageController.text = "";
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
              slippageController.text = "";
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
        child: Container(
          padding: EdgeInsets.all(12.0),
          margin: EdgeInsets.all(4.0),
          decoration: slippageController.text != ""
              ? MyStyles.greenToBlueDecoration
              : MyStyles.lightBlackBorderDecoration,
          child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      inputFormatters: [
                        WhitelistingTextInputFormatter(
                            new RegExp(r'([0-9]+([.][0-9]*)?|[.][0-9]+)'))
                      ],
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      controller: slippageController,
                      style: slippageController.text != ""
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
                    style: slippageController.text != ""
                        ? MyStyles.blackSmallTextStyle
                        : MyStyles.whiteSmallTextStyle,
                  ),
                ],
              )),
        ),
      ),
    ]);
  }

  Future approve() async {
    if (!isInProgress) {
      setState(() {
        isInProgress = true;
        toastMessage = "Approve ${swapModel.from.name}";
        showingToast = true;
      });
      var res = await swapService.approve(swapModel.from.getTokenName());
      Stream<TransactionReceipt> result =
          swapService.ethService.pollTransactionReceipt(res);
      result.listen((event) {
        setState(() {
          isInProgress = false;
          showingToast = false;
          swapModel.approved = event.status;
        });
        if (event.status) {
          showToast(
              context,
              TransactionStatus("Approved ${swapModel.from.name}",
                  TransactionStatus.SUCCESSFUL, "Successful"));
        } else {
          showToast(
              context,
              TransactionStatus("Approve of ${swapModel.from.name}",
                  TransactionStatus.FAILED, "Failed"));
        }
      });
    }
  }

  getAllowances() async {
    if (swapModel.from.getTokenName() != "eth") {
      setState(() {
        isInProgress = true;
      });
    }
    swapService.getAllowances(swapModel.from.getTokenName()).then((value) {
      setState(() {
        swapModel.from.allowances = value;
        isInProgress = false;
      });
    });
  }

  Future swapTokens() async {
    if (!isInProgress && swapModel.approved) {
      Transaction transaction = await swapService.makeSwapTransaction(
          swapModel.from.getTokenName(),
          swapModel.to.getTokenName(),
          fromFieldController.text,
          ((1 - getSlippage()) * double.parse(toFieldController.text))
              .toString());

      Gas gas = await showConfirmGasFeeDialog(transaction);

      if (gas != null) {
        setState(() {
          isInProgress = true;
          toastMessage = "Swap ${toFieldController.text} ${swapModel.to.getTokenName()} for ${fromFieldController.text} ${swapModel.from.getTokenName()}";
          showingToast = true;
        });

        try {
          var res = await swapService.swapTokens(
              swapModel.from.getTokenName(),
              swapModel.to.getTokenName(),
              fromFieldController.text,
              ((1 - getSlippage()) * double.parse(toFieldController.text))
                  .toString(),
              gas);
          Stream<TransactionReceipt> result =
              swapService.ethService.pollTransactionReceipt(res);
          result.listen((event) async {
            setState(() {
              isInProgress = false;
              showingToast = false;
            });
            if (event.status) {
              showToast(
                  context,
                  new TransactionStatus(
                      "Swapped ${toFieldController.text} ${swapModel.to.getTokenName()} for ${fromFieldController.text} ${swapModel.from.getTokenName()}",
                      TransactionStatus.SUCCESSFUL, "Successful"));
              getTokenBalance(swapModel.from);
              getTokenBalance(swapModel.to);
            } else {
              showToast(
                  context,
                  new TransactionStatus(
                      "Not Swapped ${toFieldController.text} ${swapModel.to.getTokenName()} for ${fromFieldController.text} ${swapModel.from.getTokenName()}",
                      TransactionStatus.FAILED, "Failed"));
            }
          });
        } on Exception catch (error) {
          print(error);
          setState(() {
            isInProgress = false;
            showingToast = false;
          });
          showToast(
              context,
              new TransactionStatus(
                  "Not Swapped ${toFieldController.text} ${swapModel.to.getTokenName()} for ${fromFieldController.text} ${swapModel.from.getTokenName()}",
                  TransactionStatus.FAILED, "Failed"));
        }
      }
      else{
        showToast(
            context,
            new TransactionStatus(
                "Transaction Rejected",
                TransactionStatus.FAILED, "Failed"));
      }
    }
  }

  getSlippage() {
    return swapModel.slippage / 100;
  }

  Future<void> listenInput() async {
    String input = fromFieldController.text;
    if (input == null || input.isEmpty) {
      input = "0.0";
    }
    if (swapModel.from.getAllowances() >= EthereumService.getWei(input)) {
      swapModel.approved = true;
    } else {
      swapModel.approved = false;
    }
    setState(() {});
    streamController.add(input);
  }

  computePriceImpact(String _input, String _y) async {
    double x = double.parse(await swapService.getAmountsOut(
        swapModel.from.getTokenName(), swapModel.to.getTokenName(), "0.1"));
    double r = 0.1;
    double input = double.tryParse(_input) ?? 0;
    double y = double.tryParse(_y) ?? 0;

    double v = 1.0;
    if (input != 0) {
      v = y / (x * (input / r));
    }
    setState(() {
      priceImpact = double.parse(((1.0 - v) * 100.0).toStringAsFixed(3));
    });
  }

  void getTokenBalance(Token token) async {
    swapService.getTokenBalance(token.getTokenName()).then((value) {
      token.balance = value;
      setState(() {});
    });
  }
}
