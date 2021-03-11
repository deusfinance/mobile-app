import 'package:flutter/material.dart';

Future<bool> showWillPopDialog(BuildContext context) async {
  final Widget dialog = AlertDialog(
    title: Text('Are you sure?'),
    content: Text('Do you want to exit the DEUS App_'),
    actions: <Widget>[
      FlatButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text('No'),
      ),
      FlatButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text('Yes'),
      ),
    ],
  );
  return (await showDialog(context: context, builder: (context) => dialog)) ?? false;
}
