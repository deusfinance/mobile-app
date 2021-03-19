import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:flutter/material.dart';

import '../../../locator.dart';

Future<bool> showWillPopDialog(BuildContext context) async {
  final Widget dialog = AlertDialog(
    title: Text('Are you sure?'),
    content: Text('Do you want to exit the DEUS App?'),
    actions: <Widget>[
      FlatButton(
        onPressed: () => locator<NavigationService>().goBack(context, false),
        child: Text('No'),
      ),
      FlatButton(
        onPressed: () => locator<NavigationService>().goBack(context, true),
        child: Text('Yes'),
      ),
    ],
  );
  return (await showDialog(context: context, builder: (context) => dialog)) ?? false;
}
