import 'dart:ui';

import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

import '../../../locator.dart';

class TokenSelector extends StatelessWidget {
  final Widget selector;
  final bool showSearchBar;
  final String title;
  final TextEditingController? searchController;

  TokenSelector(
      {required this.selector,
      required this.title,
      this.showSearchBar = false,
      this.searchController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                // Text(title),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      locator<NavigationService>().goBack(context);
                    }),
              ],
            ),
            SizedBox(
              height: 12,
            ),
            !showSearchBar
                ? const Divider(
                    height: 1,
                  )
                : SizedBox(
                    height: 55,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: const Color.fromRGBO(17, 17, 17, 1),
                          border: Border.all(color: MyColors.Black),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: searchController,
                        style: MyStyles.whiteMediumTextStyle,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: MyColors.White,
                            size: 20,
                          ),
                          hintText: "Search Asset",
                          hintStyle: MyStyles.lightWhiteMediumTextStyle,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [Text(title), const Spacer(), const Text('Balance')],
            ),
            const Divider(
              height: 10,
            ),
            Expanded(child: selector),
          ],
        ),
      ),
    );
  }
}
