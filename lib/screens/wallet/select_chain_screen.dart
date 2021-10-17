import '../../core/database/chain.dart';
import '../../core/util/responsive.dart';
import '../../core/widgets/selection_button.dart';
import '../../routes/navigation_service.dart';
import '../../statics/my_colors.dart';
import '../../statics/styles.dart';
import 'package:flutter/material.dart';

import '../../locator.dart';

class SelectChainScreen extends StatefulWidget {
  final Chain selectedChain;
  final Stream<List<Chain>> chains;
  final void Function(Chain chain) onChainSelected;
  final void Function() addChain;
  final void Function(Chain chain) deleteChain;
  final void Function(Chain chain) updateChain;

  SelectChainScreen(
      {required this.selectedChain,
      required this.chains,
      required this.onChainSelected,
      required this.addChain,
      required this.deleteChain,
      required this.updateChain});

  @override
  _SelectChainScreenState createState() => _SelectChainScreenState();
}

class _SelectChainScreenState extends State<SelectChainScreen> {
  Chain? selectedChain;

  @override
  void initState() {
    if (selectedChain == null) selectedChain = widget.selectedChain;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 450,
        width: getScreenWidth(context) - 50,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            border: Border.all(
                color:
                    const Color(MyColors.kAddressBackground).withOpacity(0.5)),
            color: const Color(MyColors.kAddressBackground).withOpacity(0.25),
            borderRadius: const BorderRadius.all(Radius.circular(6))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Select Network',
                      style: MyStyles.whiteSmallTextStyle,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    locator<NavigationService>().goBack(context);
                    widget.addChain();
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 20),
                      Container(
                        padding: const EdgeInsets.all(8),
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
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: StreamBuilder<List<Chain>>(
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
                            final Chain chain = snapshot.data![index];
                            return GestureDetector(
                              onTap: () {
                                selectedChain = chain;
                                setState(() {});
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient:
                                        chain.id == (selectedChain?.id ?? 0)
                                            ? MyColors.greenToBlueGradient
                                            : null,
                                    border: Border.all(color: Colors.white)),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          chain.name,
                                          style: chain.id ==
                                                  (selectedChain?.id ?? 0)
                                              ? MyStyles.blackMediumTextStyle
                                              : MyStyles.whiteMediumTextStyle,
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
                                                  widget.updateChain(chain);
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(1.0),
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  widget.deleteChain(chain);
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
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
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: SelectionButton(
                label: 'Select Network',
                onPressed: (bool selected) async {
                  widget.onChainSelected(selectedChain!);
                  locator<NavigationService>().goBack(context);
                },
                selected: true,
                gradient: MyColors.greenToBlueGradient,
                textStyle: MyStyles.blackMediumTextStyle,
              ),
            ),
          ],
        ));
  }
}
