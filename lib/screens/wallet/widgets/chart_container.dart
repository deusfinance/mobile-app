import 'package:deus_mobile/core/widgets/custom_chart.dart';
import 'package:deus_mobile/models/chart_data_point.dart';
import 'package:deus_mobile/models/value_locked_chart_data.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ChartContainer extends StatefulWidget {
  final Future<List<ChartDataPoint>> chartPoints;

  ChartContainer({this.chartPoints});

  @override
  _ChartContainerState createState() => _ChartContainerState();
}

class _ChartContainerState extends State<ChartContainer> {
  Future<ValueLockedChartData> futureData;

  SizedBox _bigHeightDivider = SizedBox(
    height: 20,
  );
  SizedBox _midHeightDivider = SizedBox(
    height: 10,
  );
  SizedBox _smallHeightDivider = SizedBox(
    height: 5,
  );

  Future<ValueLockedChartData> _getFutureChartData(Duration duration) async {
    ValueLockedChartData _randomTestData = ValueLockedChartData(
        lockedInCash: 563008.67,
        lockedInCrypto: 478.939,
        absoluteChange: 140355.32,
        relativeChange: 25.42,
        chartDataPoints: List.generate(
            100,
            (index) => ChartDataPoint(
                dateTime: DateTime.now().subtract(duration),
                value: Random().nextInt(500) / 100)));
    // _randomTestData.chartDataPoints.removeWhere((value) {
    //   return DateTime.now().difference(value.dateTime) >= duration;
    // });
    await Future.delayed(Duration(seconds: 5));
    return _randomTestData;
  }

  Map<Duration, String> _durationTimeSpan = {
    Duration(hours: 1): 'Past Hour',
    Duration(days: 1): 'Past Day',
    Duration(days: 7): 'Past Week',
    Duration(days: 30): 'Past Month',
    Duration(days: 365): 'Past Year',
  };

  String timeSpanOfChart = 'Past Week';
  Duration _displayedChartDuration = Duration(days: 7);

  void _onTimeSelected(Duration dur) {
    setState(() {
      _displayedChartDuration = dur;
      timeSpanOfChart = _durationTimeSpan[dur];
      futureData = _getFutureChartData(dur);
    });
  }

  @override
  void initState() {
    super.initState();
    futureData = _getFutureChartData(Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ValueLockedChartData>(
        future: futureData,
        builder: (context, snap) {
          return Column(children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 40),
              decoration: BoxDecoration(
                  color: Color(MyColors.kWalletFillChart),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: MyColors.HalfBlack)),
              child: Center(
                child: Text(
                  snap.connectionState == ConnectionState.done
                      ? 'TVL: ${snap.data.lockedInCrypto} ETH (\$${snap.data.lockedInCash})'
                      : 'TVL: --------- ETH(\$---------)', //TODO: Crypto kürzel

                  style: MyStyles.whiteSmallTextStyle,
                ),
              ),
            ),
            _midHeightDivider,
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Color(MyColors.kWalletFillChart),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: MyColors.HalfBlack)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  snap.connectionState == ConnectionState.done
                      ? _buildHeader(
                          snap.data.lockedInCash,
                          snap.data.lockedInCrypto,
                          snap.data.absoluteChange,
                          snap.data.relativeChange,
                          snap.connectionState)
                      : _buildHeader(
                          null, null, null, null, snap.connectionState),
                  _bigHeightDivider,
                  snap.connectionState == ConnectionState.done
                      ? CustomChart(snap.data.chartDataPoints, _onTimeSelected)
                      : Center(
                          child: CircularProgressIndicator(),
                        )
                ],
              ),
            ),
          ]);
        });
  }

  Column _buildHeader(
      double lockedInCash,
      double lockedInCrypto,
      double absoluteChange,
      double relativeChange,
      ConnectionState connectionState) {
    return Column(
      children: [
        Text(
          'YOUR VALUE LOCKED',
          style: MyStyles.lightWhiteSmallTextStyle,
        ),
        _midHeightDivider,
        Text(
          connectionState == ConnectionState.done
              ? '\$$lockedInCash / Ξ$lockedInCrypto'
              : '\$----- / -----',
          style: MyStyles.whiteMediumTextStyle,
        ),
        _midHeightDivider,
        Text(
          connectionState == ConnectionState.done
              ? '+$relativeChange% ($absoluteChange) $timeSpanOfChart'
              : '+--.--% (------) $timeSpanOfChart',
          style: MyStyles.greenSmallTextStyle,
        ),
      ],
    );
  }
}
