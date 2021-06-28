import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/widgets/selection_button.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/widgets/form/paper_input.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddChainScreen extends StatefulWidget {
  Chain? chain;


  AddChainScreen({this.chain});

  @override
  _AddChainScreenState createState() => _AddChainScreenState();
}

class _AddChainScreenState extends State<AddChainScreen> {
  final darkGrey = Color(0xFF1C1C1C);
  var chainNameController;
  var blockExplorerUrlController;
  var chainIdController;
  var RPCController;

  @override
  void initState() {
    super.initState();
    chainNameController = new TextEditingController(text: widget.chain?.name??"");
    blockExplorerUrlController = new TextEditingController(text: widget.chain?.blockExplorerUrl??"");
    chainIdController = new TextEditingController(text: widget.chain?.id.toString()??"");
    RPCController = new TextEditingController(text: widget.chain?.RPC_url??"");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: Text(
                  'Network Name',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: darkGrey,
                ),
                child: PaperInput(
                  textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  hintText: 'Network Name',
                  maxLines: 1,
                  controller: chainNameController,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: Text(
                  'Chain Id',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: darkGrey,
                ),
                child: PaperInput(
                  textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  hintText: '12',
                  maxLines: 1,
                  controller: chainIdController,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: Text(
                  'New RPC Url',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: darkGrey,
                ),
                child: PaperInput(
                  textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  hintText: 'http://...',
                  maxLines: 1,
                  controller: RPCController,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: Text(
                  'Block Explorer Url(Optional)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: darkGrey,
                ),
                child: PaperInput(
                  textStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  hintText: 'http://...',
                  maxLines: 1,
                  controller: blockExplorerUrlController,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                margin: EdgeInsets.all(8.0),
                child: SelectionButton(
                  label: widget.chain!= null ? "Edit Network":'Add Network',
                  onPressed: (bool selected) async {
                    try {
                      Chain chain = new Chain(
                          id: int.parse(chainIdController.text.toString()),
                          name: chainNameController.text.toString(),
                          RPC_url: RPCController.text.toString(),
                          blockExplorerUrl: blockExplorerUrlController.text
                              .toString()
                      );
                      locator<NavigationService>().goBack(context, chain);
                    } on Exception catch(e){

                    }

                  },
                  selected: true,
                  gradient: MyColors.greenToBlueGradient,
                  textStyle: MyStyles.blackMediumTextStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
