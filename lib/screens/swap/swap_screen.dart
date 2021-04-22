import 'dart:async';
import 'dart:ui';

import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/token_selector/currency_selector_screen/currency_selector_screen.dart';
import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:deus_mobile/screens/confirm_gas/confirm_gas.dart';
import 'package:deus_mobile/service/address_service.dart';
import 'package:deus_mobile/service/config_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

import '../../core/widgets/selection_button.dart';
import '../../core/widgets/svg.dart';
import '../../core/widgets/swap_field.dart';
import '../../core/widgets/toast.dart';
import '../../locator.dart';
import '../../models/swap/gas.dart';
import '../../models/token.dart';
import '../../models/transaction_status.dart';
import '../../service/ethereum_service.dart';
import '../../statics/my_colors.dart';
import '../../statics/statics.dart';
import '../../statics/styles.dart';
import 'cubit/swap_cubit.dart';
import 'cubit/swap_state.dart';

class SwapScreen extends StatefulWidget {
  static const route = "/swap";

  const SwapScreen();

  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  @override
  void initState() {
    context.read<SwapCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapCubit, SwapState>(builder: (context, state) {
      if (state is SwapLoading) {
        return DefaultScreen(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is SwapError) {
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
        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          child: child,
          opacity: anim1,
        ),
      ),
      transitionDuration: Duration(milliseconds: 10),
    );
    return res;
  }

  Widget _buildTransactionPending(TransactionStatus transactionStatus) {
    return Container(
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGrey,
        onPressed: () {
          if (transactionStatus.hash != "") {
            _launchInBrowser(transactionStatus.transactionUrl());
          }
        },
        onClosed: () {
          context.read<SwapCubit>().closeToast();
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
          _launchInBrowser(transactionStatus.transactionUrl());
        },
        onClosed: () {
          context.read<SwapCubit>().closeToast();
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
          _launchInBrowser(transactionStatus.transactionUrl());
        },
        onClosed: () {
          context.read<SwapCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildBody(SwapState state) {
    SwapField fromField = new SwapField(
      direction: Direction.from,
      initialToken: state.fromToken,
      selectAssetRoute: CurrencySelectorScreen.url,
      controller: state.fromFieldController,
      tokenSelected: (selectedToken) {
        context.read<SwapCubit>().fromTokenChanged(selectedToken);
      },
    );

    context.read<SwapCubit>().addListenerToFromField();

    SwapField toField = new SwapField(
      direction: Direction.to,
      initialToken: state.toToken,
      selectAssetRoute: CurrencySelectorScreen.url,
      controller: state.toFieldController,
      tokenSelected: (selectedToken) {
        context.read<SwapCubit>().toTokenChanged(selectedToken);
      },
    );

    return Container(
      padding: EdgeInsets.all(MyStyles.mainPadding * 1.5),
      decoration: BoxDecoration(color: MyColors.Main_BG_Black),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                fromField,
                const SizedBox(height: 12),
                GestureDetector(
                    onTap: () {
                      context.read<SwapCubit>().reverseSwap();
                    },
                    child: Center(child: PlatformSvg.asset('images/icons/arrow_down.svg'))),
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
                          state.isPriceRatioForward
                              ? "${context.read<SwapCubit>().getPriceRatio()} ${state.fromToken != null ? state.fromToken.symbol : "asset name"} per ${state.toToken != null ? state.toToken.symbol : "asset name"}"
                              : "${context.read<SwapCubit>().getPriceRatio()} ${state.toToken != null ? state.toToken.symbol : "asset name"} per ${state.fromToken != null ? state.fromToken.symbol : "asset name"}",
                          style: MyStyles.whiteSmallTextStyle,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<SwapCubit>().reversePriceRatio();
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
                const SizedBox(height: 12),
                _buildPriceImpact(state),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Slippage Tolerance",
                    style: MyStyles.whiteSmallTextStyle,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSlippageButtons(state),
                const SizedBox(height: 12),
                _buildModeButtons(state),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Route",
                    style: MyStyles.whiteSmallTextStyle,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRouteWidget(state),
              ],
            ),
          ),
          _buildToastWidget(state),
        ],
      ),
    );
  }

  Widget _buildPriceImpact(SwapState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Price Impact",
          style: MyStyles.whiteSmallTextStyle,
        ),
        FutureBuilder(
            future: context.read<SwapCubit>().computePriceImpact(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                double p = snapshot.data;
                return Text(
                  "${p == 0 ? "0.0" : p < 0.005 ? "<0.005" : p}%",
                  style: TextStyle(
                    fontFamily: "Monument",
                    fontWeight: FontWeight.w300,
                    fontSize: MyStyles.S6,
                    color: p <= 1
                        ? Color(0xFF00D16C)
                        : (p <= 3 ? Color(0xFFFFFFFF) : (p < 5 ? Color(0xFFf58516) : Color(0xFFD40000))),
                  ),
                );
              } else {
                return Container();
              }
            }),
      ],
    );
  }

  Widget _buildModeButtons(SwapState state) {
    if (!state.swapService.checkWallet()) {
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
    } else if (!state.approved) {
      return Opacity(
        opacity: state.isInProgress ? 0.5 : 1,
        child: Container(
          child: Row(children: [
            Expanded(
              child: _buildApproveButton(state),
            ),
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: _buildSwapButton(state),
            )
          ]),
        ),
      );
    } else if (state.approved) {
      return Opacity(opacity: state.isInProgress ? 0.5 : 1, child: _buildSwapButton(state));
    } else {
      return Container();
    }
  }

  Widget _buildApproveButton(SwapState state) {
    return SelectionButton(
      label: 'Approve',
      onPressed: (bool selected) async {
        await context.read<SwapCubit>().approve();
      },
      selected: true,
      gradient: MyColors.blueToGreenSwapScreenGradient,
      textStyle: MyStyles.blackMediumTextStyle,
    );
  }

  Widget _buildRouteWidget(SwapState state) {
    return Container(
        margin: EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 30,
            child: FutureBuilder<List<Token>>(
              future: context.read<SwapCubit>().getRoute(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Token token = snapshot.data[index];
                        return SizedBox(
                          width: 120,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              token.logoPath.showCircleImage(radius: 10),
                              const SizedBox(width: 5),
                              Text(token.symbol, style: MyStyles.whiteSmallTextStyle),
                              (index < snapshot.data.length - 1)
                                  ? _buildRouteTransformWidget(snapshot.data, index)
                                  : Container(),
                            ],
                          ),
                        );
                      });
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ));
  }

  Widget _buildRouteTransformWidget(List<Token> route, int index) {
    if ((route[index].getTokenName() == "eth" && route[index + 1].getTokenName() == "deus") ||
        (route[index].getTokenName() == "deus" && route[index + 1].getTokenName() == "eth")) {
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

  Widget _buildSwapButton(SwapState state) {
    if (!state.approved) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16.0),
        decoration: MyStyles.darkWithNoBorderDecoration,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "Swap",
            style: MyStyles.lightWhiteMediumTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
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
    if (state.approved &&
        state.fromToken.getBalance() <
            EthereumService.getWei(state.fromFieldController.text, state.fromToken.getTokenName())) {
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
      label: 'SWAP',
      onPressed: (bool selected) async {
        Transaction transaction = await context.read<SwapCubit>().makeTransaction();
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        Gas gas = await showConfirmGasFeeDialog(transaction);
        await context.read<SwapCubit>().swapTokens(gas);
      },
      selected: true,
      gradient: MyColors.blueToGreenSwapScreenGradient,
      textStyle: MyStyles.blackMediumTextStyle,
    );
  }

  Widget _buildSlippageButtons(SwapState state) {
    context.read<SwapCubit>().addListenerToSlippageController();
    return Row(children: [
      Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () {
            context.read<SwapCubit>().setSlippage(0.1);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            margin: EdgeInsets.all(4.0),
            decoration:
                state.slippage == 0.1 ? MyStyles.blueToGreenSwapScreenDecoration : MyStyles.lightBlackBorderDecoration,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "0.1%",
                style: state.slippage == 0.1 ? MyStyles.blackSmallTextStyle : MyStyles.whiteSmallTextStyle,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () {
            context.read<SwapCubit>().setSlippage(0.5);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            margin: EdgeInsets.all(4.0),
            decoration:
                state.slippage == 0.5 ? MyStyles.blueToGreenSwapScreenDecoration : MyStyles.lightBlackBorderDecoration,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "0.5%",
                style: state.slippage == 0.5 ? MyStyles.blackSmallTextStyle : MyStyles.whiteSmallTextStyle,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () {
            context.read<SwapCubit>().setSlippage(1);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            margin: EdgeInsets.all(4.0),
            decoration:
                state.slippage == 1.0 ? MyStyles.blueToGreenSwapScreenDecoration : MyStyles.lightBlackBorderDecoration,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "1%",
                style: state.slippage == 1.0 ? MyStyles.blackSmallTextStyle : MyStyles.whiteSmallTextStyle,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: 6,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
          margin: EdgeInsets.all(4.0),
          decoration: state.slippageController.text != ""
              ? MyStyles.greenToBlueDecoration
              : MyStyles.lightBlackBorderDecoration,
          child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      // textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      autofocus: false,
                      inputFormatters: [WhitelistingTextInputFormatter(new RegExp(r'([0-9]+([.][0-9]*)?|[.][0-9]+)'))],
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      controller: state.slippageController,
                      style: state.slippageController.text != ""
                          ? MyStyles.blackSmallTextStyle
                          : MyStyles.whiteSmallTextStyle,
                      decoration: InputDecoration(
                        hintTextDirection: TextDirection.rtl,
                        hintText: "0.50",
                        hintStyle: MyStyles.lightWhiteSmallTextStyle,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      ),
                    ),
                  ),
                  Text(
                    "%",
                    style: state.slippageController.text != ""
                        ? MyStyles.blackSmallTextStyle
                        : MyStyles.whiteSmallTextStyle,
                  ),
                ],
              )),
        ),
      ),
    ]);
  }

  Widget _buildToastWidget(SwapState state) {
    if (state is TransactionPendingState && state.showingToast) {
      return Align(alignment: Alignment.bottomCenter, child: _buildTransactionPending(state.transactionStatus));
    } else if (state is TransactionFinishedState && state.showingToast) {
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
}
