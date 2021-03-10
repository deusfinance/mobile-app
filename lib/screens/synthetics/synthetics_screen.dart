
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web3dart/web3dart.dart';

import '../../core/widgets/filled_gradient_selection_button.dart';
import '../../core/widgets/selection_button.dart';
import '../../core/widgets/svg.dart';
import '../../core/widgets/swap_field.dart';
import '../../data_source/currency_data.dart';
import '../../data_source/stock_data.dart';
import '../../models/stock_address.dart';
import '../../models/synthetic_model.dart';
import '../../models/token.dart';
import '../../models/transaction_status.dart';
import '../../service/ethereum_service.dart';
import '../../service/stock_service.dart';
import '../../statics/my_colors.dart';
import '../../statics/statics.dart';
import '../../statics/styles.dart';
import 'market_timer.dart';

class SyntheticsScreen extends StatefulWidget {
  @override
  _SyntheticsScreenState createState() => _SyntheticsScreenState();
}

class _SyntheticsScreenState extends State<SyntheticsScreen> {
  SyntheticModel syntheticModel;
  StockService stockService;
  TextEditingController fromFieldController = new TextEditingController();
  TextEditingController toFieldController = new TextEditingController();
  StreamController<String> streamController = StreamController();
  bool isInProgress = false;
  bool isPriceRatioForward = true;


  @override
  void initState() {
    super.initState();
    _init();
    fetchBalance();
  }

  fetchBalance(){
    getTokenBalance(syntheticModel.from);
    syntheticModel.syntheticState = SyntheticState.openMarket;
  }

  _init() {
    stockService = new StockService(
        ethService: new EthereumService(4),
        privateKey:
            "0xefadf3f48a2fd1c1815b153a7e134451df88c70e54630eb36323f2a0a555eaa3");
    syntheticModel = new SyntheticModel();
    streamController.stream
        .transform(debounce(Duration(milliseconds: 500)))
        .listen((s) async {
      if (double.tryParse(s) != null && double.tryParse(s) > 0) {
        StockData.getPrices();
      } else {
        setState(() {
          toFieldController.text = "0.0";
        });
      }
    });
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

  Widget _buildUserInput(BuildContext context) {
    SwapField fromField = new SwapField(
        direction: Direction.from,
        initialToken: syntheticModel.from,
        page: TabPage.synthetics,
        controller: fromFieldController,
        tokenSelected: (selectedToken) async {
          setState(() {
            syntheticModel.to = CurrencyData.dai;
            syntheticModel.from = selectedToken;
            if (syntheticModel.selectionMode == SelectionMode.none) {
              syntheticModel.selectionMode = SelectionMode.long;
            }
            fromFieldController.text = "";
            toFieldController.text = "";
          });
          await getAllowances();
          getTokenBalance(syntheticModel.from);
        });
    if (!fromFieldController.hasListeners) {
      fromFieldController.addListener(() {
        listenInput();
      });
    }
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
          fromFieldController.text = "";
          toFieldController.text = "";
        });
        getTokenBalance(syntheticModel.to);
      },
    );
    return Column(
      children: [
        fromField,
        const SizedBox(height: 12),
        GestureDetector(
            onTap: () {
              setState(() {
                var a = syntheticModel.from;
                syntheticModel.from = syntheticModel.to;
                syntheticModel.to = a;
                fromFieldController.text = "";
                toFieldController.text = "";
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
                  isPriceRatioForward
                      ? "${_getPriceRatio()} ${syntheticModel.from != null ? syntheticModel.from.symbol : "asset name"} per ${syntheticModel.to != null ? syntheticModel.to.symbol : "asset name"}"
                      : "${_getPriceRatio()} ${syntheticModel.to != null ? syntheticModel.to.symbol : "asset name"} per ${syntheticModel.from != null ? syntheticModel.from.symbol : "asset name"}",
                  style: MyStyles.whiteSmallTextStyle,
                ),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      isPriceRatioForward = !isPriceRatioForward;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 4.0),
                    child:
                        PlatformSvg.asset("images/icons/exchange.svg", width: 15),
                  ),
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
    if (syntheticModel.syntheticState == SyntheticState.closedMarket) {
      return Container(
        width: MediaQuery.of(context).size.width,
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
        width: MediaQuery.of(context).size.width,
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
    if(!syntheticModel.approved){
      return FilledGradientSelectionButton(
        label: 'Approve',
        onPressed: () async {
          approve();
        },
        gradient: MyColors.blueToPurpleGradient,
      );
    }
    if (syntheticModel.from.getBalance() <
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
  }

  Future getAllowances() async {
    if (syntheticModel.from.getTokenName() == "dai") {
      setState(() {
        isInProgress = true;
      });
    }
    stockService.getAllowances(syntheticModel.from.getTokenName()).then((value) {
      setState(() {
        syntheticModel.from.allowances = value;
        isInProgress = false;
      });
    });
  }

  Future approve() async {
    if (!isInProgress) {
      setState(() {
        isInProgress = true;
      });
      showToast(
          context,
          TransactionStatus(
              "Approve ${syntheticModel.from.name}", Status.PENDING, "Pending"));

      var res = await stockService.approve(syntheticModel.from.getTokenName());
      Stream<TransactionReceipt> result =
      stockService.ethService.pollTransactionReceipt(res);
      result.listen((event) {
        setState(() {
          isInProgress = false;
          syntheticModel.approved = event.status;
        });
        if (event.status) {
          showToast(
              context,
              TransactionStatus("Approved ${syntheticModel.from.name}",
                  Status.SUCCESSFUL, "Successful"));
        } else {
          showToast(
              context,
              TransactionStatus("Approve of ${syntheticModel.from.name}",
                  Status.FAILED, "Failed"));
        }
      });
    }
  }

  Future sell() async {
    if (!isInProgress) {
      setState(() {
        isInProgress = true;
      });
      String tokenAddress;
      if(syntheticModel.from.getTokenName() == "dai"){
        tokenAddress = await stockService.ethService.getTokenAddrHex("dai", "token");
      }else{
        StockAddress stockAddress = StockData.getStockAddress(syntheticModel.from);
        tokenAddress = syntheticModel.selectionMode == SelectionMode.long? stockAddress.long: stockAddress.short;
      }
      var res = await stockService.sell(tokenAddress, fromFieldController.text, null);
      Stream<TransactionReceipt> result =
      stockService.ethService.pollTransactionReceipt(res);
      result.listen((event) {
        setState(() {
          isInProgress = false;
          syntheticModel.approved = event.status;
        });
        if (event.status) {
          showToast(
              context,
              TransactionStatus("Sell ${syntheticModel.from.name}",
                  Status.SUCCESSFUL, "Failed"));
        } else {
          showToast(
              context,
              TransactionStatus("Sell of ${syntheticModel.from.name}",
                  Status.FAILED, "Failed"));
        }
      });
    }
  }

  Future buy() async {
    if (!isInProgress) {
      setState(() {
        isInProgress = true;
      });
      String tokenAddress;
      if(syntheticModel.from.getTokenName() == "dai"){
        tokenAddress = await stockService.ethService.getTokenAddrHex("dai", "token");
      }else{
        StockAddress stockAddress = StockData.getStockAddress(syntheticModel.from);
        tokenAddress = syntheticModel.selectionMode == SelectionMode.long? stockAddress.long: stockAddress.short;
      }

      var res = await stockService.buy(tokenAddress, fromFieldController.text, null);
      Stream<TransactionReceipt> result =
      stockService.ethService.pollTransactionReceipt(res);
      result.listen((event) {
        setState(() {
          isInProgress = false;
          syntheticModel.approved = event.status;
        });
        if (event.status) {
          showToast(
              context,
              TransactionStatus("Buy ${syntheticModel.from.name}",
                  Status.SUCCESSFUL, "Successful"));
        } else {
          showToast(
              context,
              TransactionStatus("Buy of ${syntheticModel.from.name}",
                  Status.FAILED, "Failed"));
        }
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
          syntheticModel.selectionMode = SelectionMode.long;
        });
      },
      selected: syntheticModel.selectionMode == SelectionMode.long,
      gradient: MyColors.blueToPurpleGradient,
    );
  }

  void listenInput() {
    String input = fromFieldController.text;
    if (input == null || input.isEmpty) {
      input = "0.0";
    }
    if (syntheticModel.from.getAllowances() >= EthereumService.getWei(input)) {
      syntheticModel.approved = true;
    } else {
      syntheticModel.approved = false;
    }
    setState(() {});
    streamController.add(input);
  }

  void getTokenBalance(Token token) async {
    String tokenAddress;
    if(token.getTokenName() == "dai"){
      tokenAddress = await stockService.ethService.getTokenAddrHex("dai", "token");
    }else{
      StockAddress stockAddress = StockData.getStockAddress(token);
      tokenAddress = syntheticModel.selectionMode == SelectionMode.long? stockAddress.long: stockAddress.short;
    }
    stockService.getTokenBalance(tokenAddress).then((value) {
      token.balance = value;
      setState(() {});
    });

  }
}
