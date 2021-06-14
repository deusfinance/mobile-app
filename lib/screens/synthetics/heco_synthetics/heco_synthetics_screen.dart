import 'dart:async';
import 'dart:ui';

import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/default_screen/sync_chain_selector.dart';
import 'package:deus_mobile/core/widgets/toast.dart';
import 'package:deus_mobile/core/widgets/token_selector/bsc_stock_selector_screen/bsc_stock_selector_screen.dart';
import 'package:deus_mobile/core/widgets/token_selector/heco_stock_selector_screen/bsc_stock_selector_screen.dart';
import 'package:deus_mobile/core/widgets/token_selector/stock_selector_screen/stock_selector_screen.dart';
import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/screens/confirm_gas/confirm_gas.dart';
import 'package:deus_mobile/screens/synthetics/xdai_synthetics/cubit/xdai_synthetics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/widgets/filled_gradient_selection_button.dart';
import '../../../core/widgets/selection_button.dart';
import '../../../core/widgets/svg.dart';
import '../../../core/widgets/swap_field.dart';
import '../../../data_source/currency_data.dart';
import '../../../models/transaction_status.dart';
import '../../../service/ethereum_service.dart';
import '../../../statics/my_colors.dart';
import '../../../statics/styles.dart';
import '../market_timer.dart';
import 'cubit/heco_synthetics_cubit.dart';
import 'cubit/heco_synthetics_state.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as provider;

class HecoSyntheticsScreen extends StatefulWidget {
  static const route = '/heco_synthethics';

  @override
  _HecoSyntheticsScreenState createState() => _HecoSyntheticsScreenState();
}

class _HecoSyntheticsScreenState extends State<HecoSyntheticsScreen> {
  @override
  void initState() {
    context.read<HecoSyntheticsCubit>().init();
    super.initState();
  }

  @override
  void deactivate() {
    context.read<HecoSyntheticsCubit>().dispose();
    super.deactivate();
  }

  Widget _buildTransactionPending(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGrey,
        onPressed: () {
          if (transactionStatus.hash != "") {
            //TODO
            _launchInBrowser(transactionStatus.transactionUrl(chainId: 97));
          }
        },
        onClosed: () {
          context.read<HecoSyntheticsCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionSuccessFul(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGreen,
        onPressed: () {
          _launchInBrowser(transactionStatus.transactionUrl(chainId: 1));
        },
        onClosed: () {
          context.read<HecoSyntheticsCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionFailed(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastRed,
        onPressed: () {
          _launchInBrowser(transactionStatus.transactionUrl(chainId: 1));
        },
        onClosed: () {
          context.read<HecoSyntheticsCubit>().closeToast();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      child: BlocBuilder<HecoSyntheticsCubit, HecoSyntheticsState>(
          builder: (context, state) {
        if (state is HecoSyntheticsLoadingState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is HecoSyntheticsErrorState) {
          return Center(
            child: Icon(Icons.refresh, color: MyColors.White),
          );
        }
        return _buildBody(state);
      }),
      chainSelector: SyncChainSelector(SyncChains.HECO),
    );
  }

  Future<Gas> showConfirmGasFeeDialog(Transaction transaction) async {
    Gas res = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
          alignment: Alignment.center,
          child: ConfirmGasScreen(
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

  Widget _buildBody(HecoSyntheticsState state) {
    return Container(
      padding: EdgeInsets.all(MyStyles.mainPadding * 1.5),
      decoration: BoxDecoration(color: MyColors.Main_BG_Black),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(child: _buildUserInput(state)),
              _buildMarketTimer(state)
            ],
          ),
          _buildToastWidget(state),
        ],
      ),
    );
  }

  Widget _buildUserInput(HecoSyntheticsState state) {
    SwapField fromField = new SwapField(
        direction: Direction.from,
        initialToken: state.fromToken,
        selectAssetRoute: HecoStockSelectorScreen.url,
        controller: state.fromFieldController,
        tokenSelected: (selectedToken) async {
          context.read<HecoSyntheticsCubit>().fromTokenChanged(selectedToken);
        });

    context.read<HecoSyntheticsCubit>().addListenerToFromField();

    SwapField toField = new SwapField(
      direction: Direction.to,
      initialToken: state.toToken,
      controller: state.toFieldController,
      selectAssetRoute: HecoStockSelectorScreen.url,
      tokenSelected: (selectedToken) {
        context.read<HecoSyntheticsCubit>().toTokenChanged(selectedToken);
      },
    );
    return Column(
      children: [
        fromField,
        const SizedBox(height: 12),
        GestureDetector(
            onTap: () {
              context.read<HecoSyntheticsCubit>().reverseSync();
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
                      ? "${context.read<HecoSyntheticsCubit>().getPriceRatio()} ${state.fromToken != null ? state.fromToken.symbol : "asset name"} per ${state.toToken != null ? state.toToken.symbol : "asset name"}"
                      : "${context.read<HecoSyntheticsCubit>().getPriceRatio()} ${state.toToken != null ? state.toToken.symbol : "asset name"} per ${state.fromToken != null ? state.fromToken.symbol : "asset name"}",
                  style: MyStyles.whiteSmallTextStyle,
                ),
                GestureDetector(
                  onTap: () {
                    context.read<HecoSyntheticsCubit>().reversePriceRatio();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 4.0),
                    child: PlatformSvg.asset("images/icons/exchange.svg",
                        width: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Opacity(
            opacity: state.isInProgress ? 0.5 : 1,
            child: _buildMainButton(state)),
        SizedBox(
          height: 16,
        ),
        _buildRemainingCapacity(state),
      ],
    );
  }

  Widget _buildMainButton(HecoSyntheticsState state) {
    if (!state.service.checkWallet()) {
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
    if (state.marketClosed) {
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
    if (state is HecoSyntheticsSelectAssetState) {
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
    if (!state.approved) {
      return FilledGradientSelectionButton(
        label: 'Approve',
        onPressed: () async {
          Transaction transaction =
              await context.read<HecoSyntheticsCubit>().makeApproveTransaction();
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          if (transaction != null) {
            Gas gas = await showConfirmGasFeeDialog(transaction);
            context.read<HecoSyntheticsCubit>().approve(gas);
          }
        },
        gradient: MyColors.blueToPurpleGradient,
      );
    }

    if (state.fromFieldController.text == "" ||
        (double.tryParse(state.fromFieldController.text) != null &&
            double.tryParse(state.fromFieldController.text) == 0)) {
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

    BigInt balance = BigInt.zero;
    if (state.fromToken is CryptoCurrency) {
      balance = (state.fromToken as CryptoCurrency).getBalance();
    } else {
      balance = (state.fromToken as Stock).getBalance();
    }
    if (balance <
        EthereumService.getWei(
            state.fromFieldController.text, state.fromToken.getTokenName())) {
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
      label: state.fromToken == CurrencyData.dai ? 'Buy' : 'Sell',
      onPressed: () async {
        if (state.fromToken == CurrencyData.dai) {
          Transaction transaction =
              await context.read<HecoSyntheticsCubit>().makeBuyTransaction();
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          if (transaction != null) {
            Gas gas = await showConfirmGasFeeDialog(transaction);
            context.read<HecoSyntheticsCubit>().buy(gas);
          }
        } else {
          Transaction transaction =
              await context.read<HecoSyntheticsCubit>().makeSellTransaction();
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          if (transaction != null) {
            Gas gas = await showConfirmGasFeeDialog(transaction);
            context.read<HecoSyntheticsCubit>().sell(gas);
          }
        }
      },
      gradient: MyColors.blueToPurpleGradient,
    );
  }

  Container _buildModeButtons(HecoSyntheticsState state) {
    return Container(
      child: Row(children: [
        Expanded(child: _buildLongButton(state)),
        const SizedBox(width: 8),
        Expanded(child: _buildShortButton(state)),
      ]),
    );
  }

  Widget _buildMarketTimer(HecoSyntheticsState state) {
    return SizedBox(
//      width: getScreenWidth(context) - (SynchronizerScreen.kPadding * 2),
      child: MarketTimer(
        timerColor:
            //TODO: add colors to my_colors.dart (.red and .green)
            state.marketTimerClosed
                ? const Color(0xFFD40000)
                : const Color(0xFF00D16C),
        onEnd: context.read<HecoSyntheticsCubit>().marketTimerFinished(),
        label: state.marketTimerClosed
            ? 'UNTIL TRADING OPENS'
            : 'UNTIL TRADING CLOSES',
        end: context.read<HecoSyntheticsCubit>().marketStatusChanged(),
      ),
    );
  }

  Widget _buildShortButton(HecoSyntheticsState state) {
    return SelectionButton(
      label: 'SHORT',
      onPressed: (bool selected) {
        context.read<HecoSyntheticsCubit>().setMode(Mode.SHORT);
      },
      selected: state.mode == Mode.SHORT,
      gradient: MyColors.blueToPurpleGradient,
    );
  }

  Widget _buildLongButton(HecoSyntheticsState state) {
    return SelectionButton(
      label: 'LONG',
      onPressed: (bool selected) {
        context.read<HecoSyntheticsCubit>().setMode(Mode.LONG);
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

  Widget _buildToastWidget(HecoSyntheticsState state) {
    if (state is HecoSyntheticsTransactionPendingState && state.showingToast) {
      return Align(
          alignment: Alignment.bottomCenter,
          child: _buildTransactionPending(state.transactionStatus));
    } else if (state is HecoSyntheticsTransactionFinishedState &&
        state.showingToast) {
      if (state.transactionStatus.status == Status.PENDING) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionPending(state.transactionStatus));
      } else if (state.transactionStatus.status == Status.SUCCESSFUL) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionSuccessFul(state.transactionStatus));
      } else if (state.transactionStatus.status == Status.FAILED) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionFailed(state.transactionStatus));
      }
    }
    return Container();
  }

  _buildRemainingCapacity(HecoSyntheticsState state) {
    return Row(children: [
      Text(
        "Remaining Synchronize Capacity",
        style: MyStyles.lightWhiteSmallTextStyle,
      ),
      Spacer(),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          //TODO
          CircleAvatar(
              radius: 12,
              backgroundImage:
                  provider.Svg("assets/images/currencies/busd.svg")),
          SizedBox(
            width: 6,
          ),
          FutureBuilder(
              future: context.read<HecoSyntheticsCubit>().getRemCap(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Text(
                    EthereumService.formatDouble(snapshot.data, 2),
                    overflow: TextOverflow.clip,
                    style: MyStyles.lightWhiteSmallTextStyle,
                  );
                } else {
                  return Text(
                    "---",
                    style: MyStyles.lightWhiteSmallTextStyle,
                  );
                }
              })
        ],
      ),
    ]);
  }
}
