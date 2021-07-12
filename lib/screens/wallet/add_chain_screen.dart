import 'package:deus_mobile/core/database/chain.dart';
import 'package:deus_mobile/core/widgets/selection_button.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/wallet_intro_screen/widgets/form/paper_input.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class AddChainScreen extends StatefulWidget {
  Chain? chain;


  AddChainScreen({this.chain});

  @override
  _AddChainScreenState createState() => _AddChainScreenState();
}

class _AddChainScreenState extends State<AddChainScreen> {
  final darkGrey = Color(0xFF1C1C1C);
  late TextEditingController chainNameController;
  late TextEditingController blockExplorerUrlController;
  late TextEditingController chainIdController;
  late TextEditingController RPCController;
  late TextEditingController currencySymbolController;

  bool? rpcConfirmed;



  @override
  void initState() {
    super.initState();
    chainNameController = new TextEditingController(text: widget.chain?.name??"");
    blockExplorerUrlController = new TextEditingController(text: widget.chain?.blockExplorerUrl??"");
    chainIdController = new TextEditingController(text: widget.chain?.id.toString()??"");
    RPCController = new TextEditingController(text: widget.chain?.RPC_url??"");
    currencySymbolController = new TextEditingController(text: widget.chain?.currencySymbol??"");

    rpcConfirmed = false;

    if(!RPCController.hasListeners){
      RPCController.addListener(() async {
        try{
        String url = RPCController.text.toString();
        Client httpClient = new Client();
        Web3Client ethClient = new Web3Client(url, httpClient);
        bool isActive = await ethClient.isListeningForNetwork();
        if (isActive) {
          int chainId = await ethClient.getNetworkId();
          setState(() {
            rpcConfirmed = true;
            chainIdController.text = chainId.toString();
          });
        } else {
          setState(() {
            rpcConfirmed = false;
          });
        }
        }catch(e){
          setState(() {
            rpcConfirmed = false;
          });
        }
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(MyColors.kAddressBorder).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(MyColors.kAddressBorder))
        ),
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        widget.chain!= null ? "Edit Network":'Add Network',
                        style: MyStyles.whiteMediumTextStyle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: (){
                        locator<NavigationService>().goBack(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios_rounded,size: 18,),
                            Text(
                              'BACK',
                              style: MyStyles.whiteMediumTextStyle,
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50,),
              form(),
              Container(
                margin: EdgeInsets.all(8.0),
                child: SelectionButton(
                  label: widget.chain!= null ? "Save Changes":'Add Network',
                  onPressed: (bool selected) async {
                    if(rpcConfirmed??false) {
                      try {
                        Chain chain = new Chain(
                            id: int.parse(chainIdController.text.toString()),
                            name: chainNameController.text.toString(),
                            RPC_url: RPCController.text.toString(),
                            blockExplorerUrl: blockExplorerUrlController.text
                                .toString()
                        );
                        locator<NavigationService>().goBack(context, chain);
                      } on Exception catch (e) {

                      }
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

  Widget form(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'Network Name',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: EdgeInsets.only(left:4),
            decoration: BoxDecoration(
                color: Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)
            ),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: chainNameController,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )
        ),
        SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'New RPC Url',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: EdgeInsets.only(left:4),
            decoration: BoxDecoration(
                color: Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)
            ),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: RPCController,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )
        ),
        Visibility(
          visible: RPCController.text.toString().length > 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 5, top: 6),
            child: Text(
              rpcConfirmed??false
                  ? 'RPC url confirmed'
                  : 'RPC url is not valid',
              style: TextStyle(
                  fontSize: 12,
                  color: rpcConfirmed??false ? Colors.green : Colors.red),
            ),
          ),
        ),
        SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'Chain Id',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: EdgeInsets.only(left:4),
            decoration: BoxDecoration(
                color: Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)
            ),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: chainIdController,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )
        ),
        SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'Currency Symbol (Optional)',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: EdgeInsets.only(left:4),
            decoration: BoxDecoration(
                color: Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)
            ),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: currencySymbolController,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )
        ),
        SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Text(
            'Block Explorer Url (Optional)',
            style: MyStyles.lightWhiteSmallTextStyle,
          ),
        ),
        Container(
            padding: EdgeInsets.only(left:4),
            decoration: BoxDecoration(
                color: Color(MyColors.kAddressBorder).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)
            ),
            child: TextField(
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              controller: blockExplorerUrlController,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )
        ),
        SizedBox(
          height: 24,
        ),
      ],
    );
  }
}
