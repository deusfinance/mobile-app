//import 'package:deus_mobile/service/deus_swap_service.dart';
//import 'package:deus_mobile/service/ethereum_service.dart';
//import 'package:deus_mobile/service/stock_service.dart';
//import 'package:deus_mobile/statics/styles.dart';
//import 'package:flutter/material.dart';
//
/////Test Screen used to check the Deus Swap Service.
//class SwapBackendTestScreen extends StatefulWidget {
//  static const url = "/swapTest";
//
//  @override
//  _SwapBackendTestScreenState createState() => _SwapBackendTestScreenState();
//}
//
//class _SwapBackendTestScreenState extends State<SwapBackendTestScreen> {
//  SwapService swapService;
//  StockService stockService;
//  EthereumService ethereumService;
//
//  String private;
//  String public;
//  String allowance;
//  String appovalHash;
//  String receipt;
//  String receiptStream;
//  String amountOut;
//  String swapResult;
//  String ether;
//
//  TextEditingController inEditingController;
//  String outField;
//
//  @override
//  void initState() {
////    "0xbba655b0a39daea9270bbb15715c0574f1fe3409ab0b551c3fe90aace22225fc"
////  "0x8d46fdadef171f9dcd7f658a20bb19e52eae8f29074014740f999b1ec054429c"
//
//    super.initState();
//    ethereumService = EthereumService(4);
//    swapService = SwapService(
//        ethService: ethereumService,
//        privateKey:
//            "0xefadf3f48a2fd1c1815b153a7e134451df88c70e54630eb36323f2a0a555eaa3");
//
//    stockService = StockService(
//        ethService: ethereumService,
//        privateKey:
//            "0xefadf3f48a2fd1c1815b153a7e134451df88c70e54630eb36323f2a0a555eaa3");
//    inEditingController = TextEditingController();
//  }
//
//  String _fromWei(BigInt value, String token) {
//    var max = 18;
//    String ans = value.toString();
//
//    while (ans.length < max) {
//      ans = "0" + ans;
//    }
//    ans = ans.substring(0, ans.length - max) +
//        "." +
//        ans.substring(ans.length - max);
//    if (ans[0] == ".") {
//      ans = "0" + ans;
//    }
//    return ans;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Container(
//        margin: EdgeInsets.all(12.0),
//        child: SingleChildScrollView(
//          child: Column(
//            children: [
//              SizedBox(
//                height: 50,
//              ),
////              Text(
////                "stock",
////                style: MyStyles.whiteMediumTextStyle,
////              ),
////              RaisedButton(
////                child: Text(
////                  "Get Allowance",
////                  style: MyStyles.whiteMediumTextStyle,
////                ),
////                onPressed: () async {
////                  print("Allowance");
////                  await stockService
////                      .getAllowances("dai")
////                      .then((value) => setState(() {
////                            allowance = value;
////                          }));
////                  print("Allowance finished");
////                },
////              ),
////              SelectableText(
////                allowance ?? "Empty",
////                style: MyStyles.whiteMediumTextStyle,
////              ),
////
////              RaisedButton(
////                child: Text(
////                  "Approve",
////                  style: MyStyles.whiteMediumTextStyle,
////                ),
////                onPressed: () async {
////                  print("Approve");
////                  await stockService
////                      .approve("dai")
////                      .then((value) => setState(() {
////                            appovalHash = value;
////                          }));
////                  print("Approve finished");
////                },
////              ),
////              SelectableText(
////                appovalHash ?? "Empty",
////                style: MyStyles.whiteMediumTextStyle,
////              ),
////
////              RaisedButton(
////                child: Text(
////                  "Buy",
////                  style: MyStyles.whiteMediumTextStyle,
////                ),
////                onPressed: () async {
////                  print("Buy");
////
//////                  await stockService.buy("tsla", ).then((value) => setState(() {
//////                    appovalHash = value;
//////                  }));
////                  print("Buy finished");
////                },
////              ),
////              SelectableText(
////                appovalHash ?? "Empty",
////                style: MyStyles.whiteMediumTextStyle,
////              ),
//
//              Text(
//                "swap",
//                style: MyStyles.whiteMediumTextStyle,
//              ),
////            RaisedButton(
////              child: Text("Generate KeyPair"),
////              onPressed: () async {
////                print("Allowance");
////                final cred = ethereumService.generateKeyPair();
////                final tempPublic = (await cred.extractAddress()).hex;
////
////                setState(() {
////                  public = tempPublic;
////                  private = cred.privateKey.join();
////                });
////                print("Allowance finished");
////              },
////            ),
////            SelectableText(private ?? "Empty"),
////            SizedBox(
////              height: 8,
////            ),
////            SelectableText(public ?? "Empty"),
//            RaisedButton(
//              child: Text("Get Allowance"),
//              onPressed: () async {
//                print("Allowance");
//                await swapService.getAllowances("deus").then((value) => setState(() {
//                      allowance = value;
//                    }));
//                print("Allowance finished");
//              },
//            ),
//            SelectableText(allowance ?? "Empty"),
//            RaisedButton(
//              child: Text("Approve"),
//              onPressed: () async {
//                print("Approve");
//                await swapService.approve("deus").then((value) => setState(() {
//                      appovalHash = value;
//                    }));
//                print("Approve finished");
//              },
//            ),
//            SelectableText(appovalHash ?? "Empty"),
//            RaisedButton(
//              child: Text("Get Receipt"),
//              onPressed: appovalHash == null || appovalHash.isEmpty
//                  ? null
//                  : () async {
//                      var result = await ethereumService.getTransactionReceipt(appovalHash);
//                      setState(() {
//                        if (result == null) {
//                          receipt = "Currently null";
//                        } else {
//                          receipt =
//                              "from: ${result.from}; to: ${result.to}; status: ${result.status}; hash: ${result.transactionHash}; blockNumber: ${result.blockNumber.blockNum};";
//                        }
//                      });
//                    },
//            ),
//            SelectableText(receipt ?? "Empty"),
//            RaisedButton(
//              child: Text("Get Receipt Stream"),
//              onPressed: appovalHash == null || appovalHash.isEmpty
//                  ? null
//                  : () async {
//                      ethereumService.pollTransactionReceipt(appovalHash, pollingTimeMs: 1000).listen((result) {
//                        setState(() {
//                          if (result == null) {
//                            receiptStream = "Currently null";
//                          } else {
//                            receiptStream =
//                                "from: ${result.from}; to: ${result.to}; status: ${result.status}; hash: ${result.transactionHash}; blockNumber: ${result.blockNumber.blockNum};";
//                          }
//                        });
//                      });
//                    },
//            ),
//            SelectableText(receiptStream ?? "Empty"),
//            RaisedButton(
//              child: Text("getAmountsOut"),
//              onPressed: () async {
//                await swapService.getAmountsOut("deus", "eth", BigInt.from(1)).then((value) => setState(() {
//                      amountOut = value;
//                    }));
//              },
//            ),
//            SelectableText(amountOut ?? "Empty"),
//            RaisedButton(
//              child: Text("getEtherBalance"),
//              onPressed: () async {
//                await ethereumService.getEtherBalance(await swapService.credentials).then((value) => setState(() {
//                  print(value);
//                      ether = _fromWei(value.getInWei, "cascac");
//                    }));
//              },
//            ),
//            SelectableText(ether ?? "Empty"),
//            Text("In"),
//            TextField(
//              controller: inEditingController,
//              // onChanged: (input){
//              // swapService.getAmountsIn("eth", "deus", int.parse(input))
//              // },
//            ),
//            Text("Out"),
//            Text(outField ?? "0"),
//            RaisedButton(
//              child: Text("Swap"),
//              onPressed: () async {
//                print(double.parse(amountOut) * 0.995);
//                await swapService.swapTokens("eth", "deus", 1, double.parse(amountOut) * 0.995).then((value) => setState(() {
//                      swapResult = value;
//                    }));
//              },
//            ),
//            SelectableText(swapResult ?? "swapResult"),
//              RaisedButton(
//                child: Text("Get Receipt"),
//                onPressed: swapResult == null || swapResult.isEmpty
//                    ? null
//                    : () async {
//                  var result = await ethereumService.getTransactionReceipt(swapResult);
//                  setState(() {
//                    if (result == null) {
//                      receipt = "Currently null";
//                    } else {
//                      receipt =
//                      "from: ${result.from}; to: ${result.to}; status: ${result.status}; hash: ${result.transactionHash}; blockNumber: ${result.blockNumber.blockNum};";
//                    }
//                  });
//                },
//              ),
//              SelectableText(receipt ?? "Empty"),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//}
