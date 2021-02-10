import 'package:deus/service/deus_swap_service.dart';
import 'package:deus/service/ethereum_service.dart';
import 'package:flutter/material.dart';

///Test Screen used to check the Deus Swap Service.
class SwapBackendTestScreen extends StatefulWidget {
  static const url = "/swapTest";

  @override
  _SwapBackendTestScreenState createState() => _SwapBackendTestScreenState();
}

class _SwapBackendTestScreenState extends State<SwapBackendTestScreen> {
  DeusSwapService swapService;
  EthereumService ethereumService;

  String private;
  String public;
  String allowance;
  String appovalHash;
  String receipt;
  String receiptStream;
  String amountOut;
  String swapResult;
  String ether;

  TextEditingController inEditingController;
  String outField;

  @override
  void initState() {
    super.initState();
    ethereumService = EthereumService(4);
    swapService = DeusSwapService(
        ethService: ethereumService, privateKey: "0xbba655b0a39daea9270bbb15715c0574f1fe3409ab0b551c3fe90aace22225fc");
    inEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return
        // Scaffold(
        //   appBar: AppBar(),
        //   body:
        SingleChildScrollView(
      child: Column(
        children: [
          RaisedButton(
            child: Text("Generate KeyPair"),
            onPressed: () async {
              print("Allowance");
              final cred = ethereumService.generateKeyPair();
              final tempPublic = (await cred.extractAddress()).hex;

              setState(() {
                public = tempPublic;
                private = cred.privateKey.join();
              });
              print("Allowance finished");
            },
          ),
          SelectableText(private ?? "Empty"),
          SizedBox(
            height: 8,
          ),
          SelectableText(public ?? "Empty"),
          RaisedButton(
            child: Text("Get Allowance"),
            onPressed: () async {
              print("Allowance");
              await swapService.getAllowances("deus").then((value) => setState(() {
                    allowance = value;
                  }));
              print("Allowance finished");
            },
          ),
          SelectableText(allowance ?? "Empty"),
          RaisedButton(
            child: Text("Approve"),
            onPressed: () async {
              print("Approve");
              await swapService.approve("deus", BigInt.from(1000)).then((value) => setState(() {
                    appovalHash = value;
                  }));
              print("Approve");
            },
          ),
          SelectableText(appovalHash ?? "Empty"),
          RaisedButton(
            child: Text("Get Receipt"),
            onPressed: appovalHash == null || appovalHash.isEmpty
                ? null
                : () async {
                    var result = await ethereumService.getTransactionReceipt(appovalHash);
                    setState(() {
                      if (result == null) {
                        receipt = "Currently null";
                      } else {
                        receipt =
                            "from: ${result.from}; to: ${result.to}; status: ${result.status}; hash: ${result.transactionHash}; blockNumber: ${result.blockNumber.blockNum};";
                      }
                    });
                  },
          ),
          SelectableText(receipt ?? "Empty"),
          RaisedButton(
            child: Text("Get Receipt Stream"),
            onPressed: appovalHash == null || appovalHash.isEmpty
                ? null
                : () async {
                    ethereumService.pollTransactionReceipt(appovalHash, pollingTimeMs: 1000).listen((result) {
                      setState(() {
                        if (result == null) {
                          receiptStream = "Currently null";
                        } else {
                          receiptStream =
                              "from: ${result.from}; to: ${result.to}; status: ${result.status}; hash: ${result.transactionHash}; blockNumber: ${result.blockNumber.blockNum};";
                        }
                      });
                    });
                  },
          ),
          SelectableText(receiptStream ?? "Empty"),
          RaisedButton(
            child: Text("getAmountsOut"),
            onPressed: () async {
              await swapService.getAmountsOut("deus", "eth", BigInt.from(1000)).then((value) => setState(() {
                    amountOut = value;
                  }));
            },
          ),
          SelectableText(amountOut ?? "Empty"),
          RaisedButton(
            child: Text("getEtherBalance"),
            onPressed: () async {
              await ethereumService.getEtherBalance(await swapService.credentials).then((value) => setState(() {
                    ether = value.getInWei.toString();
                  }));
            },
          ),
          SelectableText(ether ?? "Empty"),
          Text("In"),
          TextField(
            controller: inEditingController,
            // onChanged: (input){
            // swapService.getAmountsIn("eth", "deus", int.parse(input))
            // },
          ),
          Text("Out"),
          Text(outField ?? "0"),
          RaisedButton(
            child: Text("Swap"),
            onPressed: () async {
              await swapService.swapTokens("eth", "deus", BigInt.from(1)).then((value) => setState(() {
                    swapResult = value;
                  }));
            },
          ),
          SelectableText(swapResult ?? "swapResult"),
        ],
      ),
    );
  }
}
