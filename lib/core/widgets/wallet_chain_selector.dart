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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WalletChainSelector extends StatefulWidget {
  Chain? selectedChain;
  Stream<List<Chain>>? chains;
  void Function(Chain chain)? onChainSelected;
  void Function()? addChain;
  void Function(Chain chain)? deleteChain;
  void Function(Chain chain)? updateChain;

  WalletChainSelector(
      {required this.selectedChain,
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
    return InkWell(
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
              Expanded(
                child: Text(
                  widget.selectedChain?.name??"--",
                  style: MyStyles.whiteSmallTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            'Select Network',
                            style: MyStyles.whiteSmallTextStyle,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          if(widget.addChain != null) {
                            locator<NavigationService>().goBack(context);
                            widget.addChain!();
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add, size:20),
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  'Add Network',
                                  style: MyStyles.whiteSmallTextStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40,
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
                                return InkWell(
                                  onTap: () {
                                    if(widget.onChainSelected != null){
                                      widget.selectedChain = chain;
                                      setState(() {});
                                      widget.onChainSelected!(chain);
                                      locator<NavigationService>()
                                          .goBack(context);
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: chain.id == (widget.selectedChain?.id??0)?MyColors.greenToBlueGradient:null,
                                        border:
                                        Border.all(color: Colors.white)),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
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
                                                  InkWell(
                                                    onTap: () {
                                                      widget.updateChain!(chain);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(8.0),
                                                      child: Image.asset('assets/icons/pencil.png', width:18, height:18),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      widget.deleteChain!(chain);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(8.0),
                                                      child: Image.asset('assets/icons/delete.png', width:18, height:18),
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
