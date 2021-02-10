import 'dart:ui';

import 'package:flutter/material.dart';

class TokenSelector extends StatelessWidget {
  final Widget selector;
  final bool showSearchBar;
  final String title;

  final textFieldBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black),
      borderRadius: BorderRadius.circular(10));

  TokenSelector(
      {@required this.selector,
      @required this.title,
      this.showSearchBar = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Row(
            children: [
              Text(title),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () {
                Navigator.pop(context);
              }),
            ],
          ),
          !showSearchBar
              ? const Divider(
                  height: 25,
                )
              : SizedBox(
                  height: 55,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(17, 17, 17, 1),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      style: const TextStyle(fontSize: 15),
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          focusedBorder: textFieldBorder,
                          errorBorder: textFieldBorder,
                          enabledBorder: textFieldBorder,
                          disabledBorder: textFieldBorder,
                          focusedErrorBorder: textFieldBorder),
                    ),
                  ),
                ),
          Row(
            children: [Text(title), const Spacer(), const Text('Balance')],
          ),
          const Divider(
            height: 10,
          ),
          selector,
          const Divider(height: 15, thickness: 1,)
        ],
      ),
    );
  }
}
