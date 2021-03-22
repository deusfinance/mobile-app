import 'package:deus_mobile/core/util/responsive.dart';
import 'package:deus_mobile/core/widgets/unicorn_outline_container.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

import 'synchronizer_screen.dart';

class MarketTimer extends StatelessWidget {
  final VoidCallback onEnd;
  final String label;
  final Color timerColor;

  final DateTime end;

  MarketTimer({
    Key key,
    @required this.onEnd,
    @required this.label,
    @required this.timerColor,
    this.end,
  }) : super(key: key);

  int get endTimeInMs {
    //TODO (@CodingDavid8): Move into cubit
    final DateTime now = DateTime.now();

    final int difference = end.difference(now).inMilliseconds;
    final int endTime = now.millisecondsSinceEpoch + difference;
    return endTime;
  }

  @override
  Widget build(BuildContext context) {
//    return UnicornOutlineContainer(
//        radius: 10,
//        strokeWidth: 1,
//        gradient: SynchronizerScreen.kGradient,
//        child: Padding(
//          padding: const EdgeInsets.symmetric(vertical: SynchronizerScreen.kPadding * 2),
//          child: Column(
//            children: [
//              CountdownTimer(
//                endTime: endTimeInMs,
//                onEnd: this.onEnd,
//                textStyle: TextStyle(fontSize: 25, height: 1, color: this.timerColor),
//              ),
//              Text(
//                this.label,
//                style: const TextStyle(fontSize: 12.5, height: 1),
//              )
//            ],
//          ),
//        ));
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
          color: MyColors.Main_BG_Black,
          border: Border.all(color: MyColors.HalfBlack, width: 1.0)),
      width: getScreenWidth(context),
      padding:
          const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          CountdownTimer(
            endTime: endTimeInMs,
            onEnd: this.onEnd,
            textStyle:
                TextStyle(fontSize: 25, height: 1, color: this.timerColor),
          ),
          SizedBox(height: 8,),
          Text(
            this.label,
            style: const TextStyle(fontSize: 12.5, height: 1),
          )
        ],
      ),
    );
  }
}
