
import 'dart:async';

import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/toast.dart';
import 'package:deus_mobile/core/widgets/token_selector/xdai_stock_selector_screen/widgets/xdai_stock_selector.dart';
import 'package:deus_mobile/core/widgets/token_selector/xdai_stock_selector_screen/xdai_stock_selector_screen.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/screens/swap/cubit/swap_cubit.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_cubit.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/widgets/filled_gradient_selection_button.dart';
import '../../../core/widgets/selection_button.dart';
import '../../../core/widgets/svg.dart';
import '../../../core/widgets/swap_field.dart';
import '../../../data_source/currency_data.dart';
import '../../../data_source/stock_data.dart';
import '../../../models/synthetics/stock_address.dart';
import '../../../models/synthetics/synthetic_model.dart';
import '../../../models/token.dart';
import '../../../models/transaction_status.dart';
import '../../../service/ethereum_service.dart';
import '../../../service/stock_service.dart';
import '../../../statics/my_colors.dart';
import '../../../statics/statics.dart';
import '../../../statics/styles.dart';
import '../market_timer.dart';

class XDaiSyntheticsScreen extends StatefulWidget {
  static const url = '/synthethics';

  @override
  _XDaiSyntheticsScreenState createState() => _XDaiSyntheticsScreenState();
}

class _XDaiSyntheticsScreenState extends State<XDaiSyntheticsScreen> {
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
    context.read<XDaiSyntheticsCubit>().init();
  }

  Widget _buildTransactionPending(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: 'Transaction Pending',
        message: transactionStatus.message,
        color: MyColors.ToastGrey,
        onPressed: () {
          if (transactionStatus.hash != "") {
            _launchInBrowser(transactionStatus.transactionUrl);
          }
        },
        onClosed: () {
          context.read<XDaiSyntheticsCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionSuccessFul(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: 'Transaction Successful',
        message: transactionStatus.message,
        color: MyColors.ToastGreen,
        onPressed: () {
          _launchInBrowser(transactionStatus.transactionUrl);
        },
        onClosed: () {
          context.read<XDaiSyntheticsCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionFailed(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: 'Transaction Failed',
        message: transactionStatus.message,
        color: MyColors.ToastRed,
        onPressed: () {
          _launchInBrowser(transactionStatus.transactionUrl);
        },
        onClosed: () {
          context.read<XDaiSyntheticsCubit>().closeToast();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<XDaiSyntheticsCubit, XDaiSyntheticsState>(builder: (context, state) {
      if (state is XDaiSyntheticsLoadingState) {
        return DefaultScreen(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is XDaiSyntheticsErrorState) {
        return DefaultScreen(
          child: Center(
            child: Icon(Icons.refresh, color: MyColors.White),
          ),
        );
      } else {
        return DefaultScreen(child: _buildBody(state));
      }
    });
  }

  Widget _buildBody(XDaiSyntheticsState state) {
    return Container(
      padding: EdgeInsets.all(MyStyles.mainPadding * 1.5),
      decoration: BoxDecoration(color: MyColors.Main_BG_Black),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildUserInput(state), _buildMarketTimer(state)],
            ),
          ),
          _buildToastWidget(state),
        ],
      ),
    );
  }

  Widget _buildUserInput(XDaiSyntheticsState state) {
    SwapField fromField = new SwapField(
        direction: Direction.from,
        initialToken: syntheticModel.from,
        page: TabPage.synthetics,
        selectAssetRoute: MaterialPageRoute<Stock>(builder: (BuildContext _) => XDaiStockSelectorScreen()),
        controller: fromFieldController,
        tokenSelected: (selectedToken) async {
          context.read<XDaiSyntheticsCubit>().fromTokenChanged(selectedToken);
        });

    context.read<XDaiSyntheticsCubit>().addListenerToFromField();

    SwapField toField = new SwapField(
      direction: Direction.to,
      controller: toFieldController,
      initialToken: syntheticModel.to,
      page: TabPage.synthetics,
      selectAssetRoute: MaterialPageRoute<Stock>(builder: (BuildContext _) => XDaiStockSelectorScreen()),
      tokenSelected: (selectedToken) {
        context.read<XDaiSyntheticsCubit>().toTokenChanged(selectedToken);
      },
    );

    return Column(
      children: [
        fromField,
        const SizedBox(height: 12),
        GestureDetector(
            onTap: () {
              context.read<XDaiSyntheticsCubit>().reverseSwap();
            },
            child: Center(
                child: PlatformSvg.asset('images/icons/arrow_down.svg'))),
        const SizedBox(height: 12),
        toField,
        const SizedBox(height: 18),
        _buildModeButtons(state),
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
                  state.isPriceRatioForward
                      ? "${context.read<XDaiSyntheticsCubit>().getPriceRatio()} ${state.fromToken != null ? state.fromToken.symbol : "asset name"} per ${state.toToken != null ? state.toToken.symbol : "asset name"}"
                      : "${context.read<XDaiSyntheticsCubit>().getPriceRatio()} ${state.toToken != null ? state.toToken.symbol : "asset name"} per ${state.fromToken != null ? state.fromToken.symbol : "asset name"}",
                  style: MyStyles.whiteSmallTextStyle,
                ),
                GestureDetector(
                  onTap: () {
                    context.read<XDaiSyntheticsCubit>().reversePriceRatio();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 4.0),
                    child: PlatformSvg.asset("images/icons/exchange.svg", width: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Opacity(opacity: isInProgress ? 0.5 : 1.0, child: _buildMainButton(state)),
      ],
    );
  }

  Widget _buildMainButton(XDaiSyntheticsState state) {
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
          // approve();
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
          // buy();
        } else {
          // sell();
        }
        ;
      },
      gradient: MyColors.blueToPurpleGradient,
    );
  }

  Container _buildModeButtons(XDaiSyntheticsState state) {
    return Container(
      child: Row(children: [
        Expanded(child: _buildLongButton(state)),
        const SizedBox(width: 8),
        Expanded(child: _buildShortButton(state)),
      ]),
    );
  }

  Widget _buildMarketTimer(XDaiSyntheticsState state) {
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

  Widget _buildShortButton(XDaiSyntheticsState state) {
    return SelectionButton(
      label: 'SHORT',
      onPressed: (bool selected) {
        context.read<XDaiSyntheticsCubit>().setMode(Mode.SHORT);
      },
      selected: state.mode == Mode.SHORT,
      gradient: MyColors.blueToPurpleGradient,
    );
  }

  Widget _buildLongButton(XDaiSyntheticsState state) {
    return SelectionButton(
      label: 'LONG',
      onPressed: (bool selected) {
        context.read<XDaiSyntheticsCubit>().setMode(Mode.LONG);
      },
      selected: state.mode == Mode.LONG,
      gradient: MyColors.blueToPurpleGradient,
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildToastWidget(XDaiSyntheticsState state) {
    if (state is XDaiSyntheticsTransactionPendingState && state.showingToast) {
      return Align(alignment: Alignment.bottomCenter, child: _buildTransactionPending(state.transactionStatus));
    } else if (state is XDaiSyntheticsTransactionFinishedState && state.showingToast) {
      if (state.transactionStatus.status == Status.PENDING) {
        return Align(alignment: Alignment.bottomCenter, child: _buildTransactionPending(state.transactionStatus));
      } else if (state.transactionStatus.status == Status.SUCCESSFUL) {
        return Align(alignment: Alignment.bottomCenter, child: _buildTransactionSuccessFul(state.transactionStatus));
      } else if (state.transactionStatus.status == Status.FAILED) {
        return Align(alignment: Alignment.bottomCenter, child: _buildTransactionFailed(state.transactionStatus));
      }
    }
    return Container();
  }
}
