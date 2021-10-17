import 'default_screen/default_screen.dart';
import '../../statics/styles.dart';
import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String imgPath;

  const ComingSoonScreen({Key? key, required this.imgPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
        showHeading: false,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.center,
                  image: AssetImage(imgPath),
                  fit: BoxFit.fill)),
          child: Center(
            child: Text('Coming Soon', style: MyStyles.whiteBigTextStyle),
          ),
        ));
  }
}
