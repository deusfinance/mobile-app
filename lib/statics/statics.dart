
import 'package:deus/models/transaction_status.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(BuildContext context, TransactionStatus status) {
  Color c;
  switch(status.status){
    case TransactionStatus.SUCCESSFUL:
      c = Color(0xFF00D16C);
      break;
    default:
      c = Color(0xFF00D16C);
  }
  Widget toast = Container(
    margin: EdgeInsets.only(bottom: 80),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: c,
    ),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.all(8.0),
            child: Icon(Icons.close, color: Color(MyColors.White),size: 15,),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top:16,bottom: 8),
          child: Text(
            status.getMessage(),
            style: MyStyles.whiteSmallTextStyle
          ),
        ),
      ],
    ),
  );

  FToast fToast = new FToast();
  fToast.init(context);

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 10),
  );
}