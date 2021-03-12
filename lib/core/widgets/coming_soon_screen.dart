import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String imgPath;

  const ComingSoonScreen({Key key, this.imgPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      showHeading: false,
        child: Stack(
      children: [
        Center(
          child: SizedBox(
            width: double.infinity,
            child: Image.asset(
              imgPath,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Center(
          child: Text('Coming Soon', style: MyStyles.whiteBigTextStyle,),
        )
      ],
    ));
  }
}
