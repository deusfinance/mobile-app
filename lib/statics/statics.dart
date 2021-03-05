
import 'package:deus_mobile/models/transaction_status.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

showToast(BuildContext context, final TransactionStatus status) {
  Color c;
  switch (status.status) {
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
    width: getScreenWidth(context),
    margin: EdgeInsets.all(8),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: c,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              status.label,
              style: MyStyles.whiteSmallTextStyle,
            ),
            Spacer(),
            GestureDetector(
                onTap: () {
                  fToast.removeCustomToast();
                },
                child: Icon(Icons.close))
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            status.message,
            style: MyStyles.whiteSmallTextStyle,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Transform.rotate(
            angle: 150,
            child: Icon(Icons.arrow_right_alt_outlined),
          ),
        )
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 8),
  );
}
