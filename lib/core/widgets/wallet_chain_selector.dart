import 'dart:ui';

import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/database/database.dart';
import 'package:deus_mobile/core/util/responsive.dart';
import 'package:deus_mobile/core/widgets/selection_button.dart';
import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

class WalletChainSelector extends StatefulWidget {
  Chain? selectedChain;
  Stream<List<Chain>> chains;
  void Function(Chain chain) onChainSelected;
  void Function() addChain;
  void Function(Chain chain) deleteChain;
  void Function(Chain chain) updateChain;

  WalletChainSelector(
      {this.selectedChain,
      required this.chains,
      required this.onChainSelected,
      required this.addChain,
      required this.deleteChain,
      required this.updateChain});

  @override
  _WalletChainSelectorState createState() => _WalletChainSelectorState();
}

class _WalletChainSelectorState extends State<WalletChainSelector> {
  @override
  Widget build(BuildContext context) {
    return _buildChainContainer();
  }

  Widget _buildChainContainer() {
    return GestureDetector(
      onTap: () {
        showChainSelectDialog();
      },
      child: Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Color(MyColors.kAddressBackground).withOpacity(0.5)),
              color: Color(MyColors.kAddressBackground).withOpacity(0.25),
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: Row(
            children: [
              Text(
                widget.selectedChain?.name ?? "--",
                style: MyStyles.whiteSmallTextStyle,
              ),
              Spacer(),
              PlatformSvg.asset('images/icons/chevron_down.svg'),
            ],
          )),
    );
  }

  void showChainSelectDialog() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: "Barrier",
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.center,
        child: Material(
          child: Container(
              height: 450,
              width: getScreenWidth(context) - 50,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                  border: Border.all(
                      color:
                          Color(MyColors.kAddressBackground).withOpacity(0.5)),
                  color: Color(MyColors.kAddressBackground).withOpacity(0.25),
                  borderRadius: BorderRadius.all(Radius.circular(6))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Select your Network',
                        style: MyStyles.whiteSmallTextStyle,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(child: StreamBuilder<List<Chain>>(
                    stream: widget.chains,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Expanded(
                          child: MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: ListView.builder(
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                Chain chain = snapshot.data![index];
                                return GestureDetector(
                                  onTap: () {
                                    widget.selectedChain = chain;
                                    setState(() {});
                                    widget.onChainSelected(chain);
                                    locator<NavigationService>()
                                        .goBack(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: chain.id == (widget.selectedChain?.id??0)?MyColors.greenToBlueGradient:null,
                                        border:
                                        Border.all(color: Colors.white)),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              chain.name,
                                              style: chain.id == (widget.selectedChain?.id??0)?MyStyles.blackMediumTextStyle:MyStyles.whiteMediumTextStyle
                                              ,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: chain.id != 1,
                                          child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      widget.updateChain(chain);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(1.0),
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      widget.deleteChain(chain);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(8.0),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: SelectionButton(
                      label: 'Add New Network',
                      onPressed: (bool selected) async {
                        locator<NavigationService>().goBack(context);
                        widget.addChain();
                      },
                      selected: true,
                      gradient: MyColors.greenToBlueGradient,
                      textStyle: MyStyles.blackMediumTextStyle,
                    ),
                  ),
                ],
              )),
        ),
      ),
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
  }
}
