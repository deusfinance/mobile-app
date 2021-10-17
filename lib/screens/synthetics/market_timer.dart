import '../../core/util/responsive.dart';
import '../../statics/my_colors.dart';
import '../../statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class MarketTimer extends StatelessWidget {
  final VoidCallback onEnd;
  final String label;
  final Color timerColor;

  final DateTime? end;

  MarketTimer({
    Key? key,
    required this.onEnd,
    required this.label,
    required this.timerColor,
    this.end,
  }) : super(key: key);

  int get endTimeInMs {
    final DateTime now = getNYC();

    final int difference = end!.difference(now).inMilliseconds;
    final int endTime =
        now.millisecondsSinceEpoch + difference + (4 * 60 * 60 * 1000);
    return endTime;
  }

  DateTime getNYC() {
    return DateTime.now().toUtc().subtract(const Duration(hours: 4));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
          color: MyColors.Main_BG_Black,
          border: Border.all(color: MyColors.HalfBlack, width: 1.0)),
      width: getScreenWidth(context),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          CountdownTimer(
            endTime: endTimeInMs,
            onEnd: this.onEnd,
            textStyle:
                TextStyle(fontSize: 25, height: 1, color: this.timerColor),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            this.label,
            style: const TextStyle(fontSize: 12.5, height: 1),
          )
        ],
      ),
    );
  }
}
