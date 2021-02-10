import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

import '../../core/widgets/unicorn_outline_container.dart';
import 'synchronizer_screen.dart';

class MarketTimer extends StatelessWidget {
  final VoidCallback onEnd;
  final String label;
  final Color timerColor;

  const MarketTimer({
    Key key,
    @required this.onEnd,
    @required this.label,
    @required this.timerColor,
  }) : super(key: key);

  int get endTimeInMs {
    //TODO (@CodingDavid8): Move into cubit
    final DateTime now = DateTime.now();
    final DateTime end = DateTime(2021, 2, 8, 6);

    final int difference = end.difference(now).inMilliseconds;
    final int endTime = DateTime.now().millisecondsSinceEpoch + difference;
    return endTime;
  }

  @override
  Widget build(BuildContext context) {
    return UnicornOutlineContainer(
        radius: 10,
        strokeWidth: 1,
        gradient: SynchronizerScreen.kGradient,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SynchronizerScreen.kPadding * 2),
          child: Column(
            children: [
              CountdownTimer(
                endTime: endTimeInMs,
                onEnd: this.onEnd,
                textStyle: TextStyle(fontSize: 25, height: 1, color: this.timerColor),
              ),
              Text(
                this.label,
                style: const TextStyle(fontSize: 12.5, height: 1),
              )
            ],
          ),
        ));
  }
}
