import '../../../routes/navigation_service.dart';
import 'package:flutter/material.dart';

import '../../../locator.dart';

Future<bool> showWillPopDialog(BuildContext context) async {
  final Widget dialog = AlertDialog(
    title: const Text('Are you sure?'),
    content: const Text('Do you want to exit the DEUS App?'),
    actions: <Widget>[
      TextButton(
        onPressed: () => locator<NavigationService>().goBack(context, false),
        child: const Text('No'),
      ),
      TextButton(
        onPressed: () => locator<NavigationService>().goBack(context, true),
        child: const Text('Yes'),
      ),
    ],
  );
  return (await showDialog(context: context, builder: (context) => dialog)) ??
      false;
}
