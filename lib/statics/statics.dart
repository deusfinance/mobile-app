
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(BuildContext context, TransactionStatus status) {
  Color c;
  switch(status.status){
    case TransactionStatus.SUCCESSFUL:
      c = Color(0xFF00D16C);
      break;
    case TransactionStatus.PENDING:
      c = Color(0xFFC4C4C4);
      break;
    case TransactionStatus.FAILED:
      c = Color(0xFFD40000);
      break;
    default:
      c = Color(0xFFC4C4C4);
  }

  FToast fToast = new FToast();
  fToast.init(context);

  Widget toast = Container(
    margin: EdgeInsets.only(bottom: 0),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: c,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: (){
              fToast.removeCustomToast();
            },
            child: Container(
              margin: EdgeInsets.only(top:8.0, right: 8.0),
              child: Icon(Icons.close, color: Color(MyColors.White),size: 15,),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Text(
              status.getMessage(),
              style: MyStyles.whiteSmallTextStyle
            ),
          ),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.CENTER,
    toastDuration: Duration(seconds: 5),
  );
}