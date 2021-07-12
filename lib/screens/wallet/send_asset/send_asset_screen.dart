import 'dart:ui';

import 'package:deus_mobile/core/database/user_address.dart';
import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/core/widgets/selection_button.dart';
import 'package:deus_mobile/core/widgets/toast.dart';
import 'package:deus_mobile/models/swap/gas.dart';
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/screens/confirm_gas/confirm_gas.dart';
import 'package:deus_mobile/screens/wallet/send_asset/cubit/send_asset_cubit.dart';
import 'package:deus_mobile/screens/wallet/send_asset/cubit/send_asset_state.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/widgets/form/paper_input.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/core/database/wallet_asset.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

class SendAssetScreen extends StatefulWidget {
  static const route = "/send_asset";

  @override
  _SendAssetScreenState createState() => _SendAssetScreenState();
}

class _SendAssetScreenState extends State<SendAssetScreen> {
  @override
  void initState() {
    context.read<SendAssetCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(child:
        BlocBuilder<SendAssetCubit, SendAssetState>(builder: (context, state) {
      if (state is SendAssetLoadingState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is SendAssetErrorState) {
        return Center(
          child: Icon(Icons.refresh, color: MyColors.White),
        );
      } else {
        return build_body(state);
      }
    }));
  }

  Future<Gas?> showConfirmGasFeeDialog(
      Transaction transaction, Network network) async {
    Gas? res = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
          alignment: Alignment.center,
          child: ConfirmGasScreen(
            transaction: transaction,
            network: network,
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

  Widget build_body(SendAssetState state) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Send Asset",
                    style: MyStyles.whiteMediumTextStyle,
                  ),
                ),
              ),
              Divider(
                height: 10,
                thickness: 2,
                color: Colors.grey.withOpacity(0.2),
              ),
              SizedBox(
                height: 16,
              ),
              //  Asset
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: state.walletAsset.logoPath != null &&
                              state.walletAsset.logoPath != ""
                          ? state.walletAsset.logoPath!
                              .showCircleImage(radius: 25)
                          // CircleAvatar(
                          //         radius: 25,
                          //         backgroundImage: NetworkImage(
                          //           walletAsset.logoPath ?? "",
                          //         ))
                          : Image.asset(
                              "assets/icons/circles.png",
                              width: 50,
                              height: 50,
                            ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              "${state.walletAsset.tokenSymbol ?? "--"}",
                              overflow: TextOverflow.ellipsis),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            state.walletAsset.tokenName ??
                                state.walletAsset.tokenAddress,
                            style: MyStyles.lightWhiteSmallTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 5),
                    child: Text(
                      'Recipient Address',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  // _savedAddress()
                ],
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColors.darkGrey,
                ),
                child: PaperInput(
                  textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  hintText: '0x..',
                  maxLines: 1,
                  controller: state.recAddressController,
                ),
              ),
              Visibility(
                visible: state.recAddressController.text.toString().length > 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 5, top: 6),
                  child: Text(
                    state.addressConfirmed
                        ? 'recipient address confirmed'
                        : 'recipient address is not valid',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            state.addressConfirmed ? Colors.green : Colors.red),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                          "Balance: ${EthereumService.formatDouble(state.walletAsset.balance ?? "0.0")}",
                          style: MyStyles.whiteSmallTextStyle,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        context.read<SendAssetCubit>().setMax();
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 25,
                      margin: EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            const Color(0xFF5BCCBD).withOpacity(0.149),
                            const Color(0xFF61C0BF).withOpacity(0.149),
                            const Color(0xFF55BCC8).withOpacity(0.149),
                            const Color(0xFF69CFB8).withOpacity(0.149)
                          ]),
                          border: Border.all(color: MyColors.White),
                          borderRadius: BorderRadius.circular(8)),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "MAX",
                            style: MyStyles.whiteSmallTextStyle,
                          )),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 5),
                child: Text(
                  'Amount',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColors.darkGrey,
                ),
                child: PaperInput(
                  textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  hintText: '',
                  maxLines: 1,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(
                        new RegExp(r'([0-9]+([.][0-9]*)?|[.][0-9]+)'))
                  ],
                  keyboardType: TextInputType.number,
                  controller: state.amountController,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Opacity(
                opacity: state.isInProgress ? 0.5 : 1,
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  child: SelectionButton(
                    label: 'Send Asset',
                    onPressed: (bool selected) async {
                      if (state.addressConfirmed) {
                        switch (state.walletService.chain.id) {
                          case 100:
                            // return "xDai";
                            Transaction? transaction = await context
                                .read<SendAssetCubit>()
                                .makeTransferTransaction();
                            WidgetsBinding.instance!.focusManager.primaryFocus
                                ?.unfocus();
                            if (transaction != null) {
                              Gas? gas = await showConfirmGasFeeDialog(
                                  transaction, Network.XDAI);
                              await context
                                  .read<SendAssetCubit>()
                                  .transfer(gas);
                            }
                            break;
                          // case 1:
                          //   return "ETH";
                          case 56:
                            // return "BSC";
                            Transaction? transaction = await context
                                .read<SendAssetCubit>()
                                .makeTransferTransaction();
                            WidgetsBinding.instance!.focusManager.primaryFocus
                                ?.unfocus();
                            if (transaction != null) {
                              Gas? gas = await showConfirmGasFeeDialog(
                                  transaction, Network.BSC);
                              await context
                                  .read<SendAssetCubit>()
                                  .transfer(gas);
                            }
                            break;
                          // case 128:
                          //   return "Heco (SOON)";
                          // case 137:
                          //   return "Matic (SOON)";
                        }
                      }
                    },
                    selected: true,
                    gradient: MyColors.greenToBlueGradient,
                    textStyle: MyStyles.blackMediumTextStyle,
                  ),
                ),
              )
            ],
          ),
        ),
        _buildToastWidget(state),
      ],
    );
  }

  Widget _buildToastWidget(SendAssetState state) {
    if (state is TransactionPendingState && state.showingToast) {
      return Align(
          alignment: Alignment.bottomCenter,
          child: _buildTransactionPending(state, state.transactionStatus));
    } else if (state is TransactionFinishedState && state.showingToast) {
      if (state.transactionStatus.status == Status.PENDING) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionPending(state, state.transactionStatus));
      } else if (state.transactionStatus.status == Status.SUCCESSFUL) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionSuccessFul(state, state.transactionStatus));
      } else if (state.transactionStatus.status == Status.FAILED) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: _buildTransactionFailed(state, state.transactionStatus));
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

  Widget _buildTransactionPending(
      SendAssetState state, TransactionStatus transactionStatus) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGrey,
        onPressed: () {
          if (transactionStatus.hash != "") {
            _launchInBrowser(transactionStatus
                .transactionUrlWithChain(state.walletService.chain));
          }
        },
        onClosed: () {
          context.read<SendAssetCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionSuccessFul(
      SendAssetState state, TransactionStatus transactionStatus) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastGreen,
        onPressed: () {
          _launchInBrowser(transactionStatus
              .transactionUrlWithChain(state.walletService.chain));
        },
        onClosed: () {
          context.read<SendAssetCubit>().closeToast();
        },
      ),
    );
  }

  Widget _buildTransactionFailed(
      SendAssetState state, TransactionStatus transactionStatus) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Toast(
        label: transactionStatus.label,
        message: transactionStatus.message,
        color: MyColors.ToastRed,
        onPressed: () {
          _launchInBrowser(transactionStatus
              .transactionUrlWithChain(state.walletService.chain));
        },
        onClosed: () {
          context.read<SendAssetCubit>().closeToast();
        },
      ),
    );
  }

  _savedAddress() {
    return StreamBuilder<List<UserAddress>>(
        stream: context.read<SendAssetCubit>().getUserAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container();
          return Container(
            margin: EdgeInsets.fromLTRB(0, 4, 12, 4),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Color(MyColors.kAddressBorder)
                        .withOpacity(0.5)),
                borderRadius:
                BorderRadius.all(Radius.circular(6))),
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            child: PopupMenuButton<UserAddress>(
              child: Text("Show Saved Addresses",
                  style: TextStyle(
                      fontFamily: MyStyles.kFontFamily,
                      fontWeight: FontWeight.w300,
                      fontSize: MyStyles.S6,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: <Color>[
                            Color(0xff0779E4),
                            Color(0xff1DD3BD)
                          ],
                        ).createShader(Rect.fromLTWH(
                            0.0, 0.0, 200.0, 70.0)))),
              padding: EdgeInsets.only(
                  top: 5, bottom: 5, right: 0, left: 5),
              color: MyColors.White,
              // icon: Icon(Icons.keyboard_arrow_down_sharp),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<UserAddress>> list = [];
                snapshot.data!.forEach((element) {
                  list.add(
                    PopupMenuItem<UserAddress>(
                        child: Container(
                          width: 150,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  element.name,
                                  style: MyStyles.blackSmallTextStyle
                                      .copyWith(fontSize: 15),
                                ),
                                Text(
                                  element.address,
                                  style: MyStyles.blackSmallTextStyle,
                                ),
                              ],
                            ),
                          ),
                        )),
                  );
                });
                return list;
              },
              onSelected: (UserAddress address) {
                context.read<SendAssetCubit>().setAddress(address);
              },
            ),
          );
        });
  }
}
