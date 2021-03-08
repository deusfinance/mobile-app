import 'package:deus/models/chart_data_point.dart';
import 'package:deus/models/value_locked_chart_data.dart';
import 'package:deus/statics/my_colors.dart';
import 'package:deus/statics/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_icons/flutter_icons.dart';

class CustomChart extends StatefulWidget {
  final double perfInPerc;
  final double perfInCash;
  final double lockedInCash;
  final double lockedInEth;
  final Future<List<ChartDataPoint>> chartPoints;

  CustomChart(
      {this.lockedInEth = 478938,
      this.lockedInCash = 563008.67,
      this.perfInCash = 130365.32,
      this.perfInPerc = 25.42,
      this.chartPoints});

  @override
  _CustomChartState createState() => _CustomChartState();
}

class _CustomChartState extends State<CustomChart> {
  SizedBox _bigHeightDivider = SizedBox(
    height: 20,
  );
  SizedBox _midHeightDivider = SizedBox(
    height: 10,
  );
  SizedBox _smallHeightDivider = SizedBox(
    height: 5,
  );

  void changeToggleButtonTime(int i) {
    if (!_toggleButtonButtonsTime[i]) {
      _toggleButtonButtonsTime = [false, false, false, false, false];
      setState(() {
        _toggleButtonButtonsTime[i] = true;
      });
    }
  }

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

  List<FlSpot> generateList(List<ChartDataPoint> values) {
    List<FlSpot> reList = [];
    double counter = 0;
    values.forEach((elem) {
      reList.add(FlSpot(counter, elem.value));
      counter++;
    });
    return reList;
  }

  String timeSpanOfChart = 'Past Week';
  List<bool> _toggleButtonButtonsTime = [false, false, true, false, false];

  Duration _displayedChartDuration = Duration(days: 7);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ValueLockedChartData>(
        future: _getFutureChartData(_displayedChartDuration),
        builder: (context, snap) {
          return Column(children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 40),
              decoration: BoxDecoration(
                  color: Color(MyColors.kWalletFillChart),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(MyColors.HalfBlack))),
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
                  border: Border.all(color: Color(MyColors.HalfBlack))),
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
                  SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: snap.connectionState == ConnectionState.done
                          ? LineChart(LineChartData(
                              minY: 0,
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              axisTitleData: FlAxisTitleData(show: false),
                              gridData: FlGridData(show: false),
                              lineBarsData: [
                                  LineChartBarData(
                                    colors: [Color(MyColors.ToastGreen)],
                                    spots:
                                        generateList(snap.data.chartDataPoints),
                                    isCurved: false,
                                    dotData: FlDotData(show: false),
                                  )
                                ]))
                          : Center(child: CircularProgressIndicator())),
                  _bigHeightDivider,
                  _buildToggleButtons()
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

  ToggleButtons _buildToggleButtons() {
    return ToggleButtons(
        splashColor: Colors.transparent,
        renderBorder: false,
        fillColor: Colors.transparent,
        onPressed: (int ind) {
          changeToggleButtonTime(ind);
          switch (ind) {
            case 0:
              {
                setState(() {
                  _displayedChartDuration = Duration(hours: 1);
                  timeSpanOfChart = 'Past Hour';
                });
              }
              break;
            case 1:
              {
                setState(() {
                  _displayedChartDuration = Duration(days: 1);
                  timeSpanOfChart = 'Past Day';
                });
              }
              break;
            case 2:
              {
                setState(() {
                  _displayedChartDuration = Duration(days: 7);
                  timeSpanOfChart = 'Past Week';
                });
              }
              break;
            case 3:
              {
                setState(() {
                  _displayedChartDuration = Duration(days: 30);
                  timeSpanOfChart = 'Past Month';
                });
              }
              break;
            case 4:
              {
                setState(() {
                  _displayedChartDuration = Duration(days: 365);
                  timeSpanOfChart = 'Past Year';
                });
              }
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Text(
              '1H',
              style: _toggleButtonButtonsTime[0]
                  ? MyStyles.selectedToggleButtonTextStyle
                  : MyStyles.unselectedToggleButtonTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Text(
              '1D',
              style: _toggleButtonButtonsTime[1]
                  ? MyStyles.selectedToggleButtonTextStyle
                  : MyStyles.unselectedToggleButtonTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Text(
              '1W',
              style: _toggleButtonButtonsTime[2]
                  ? MyStyles.selectedToggleButtonTextStyle
                  : MyStyles.unselectedToggleButtonTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Text(
              '1M',
              style: _toggleButtonButtonsTime[3]
                  ? MyStyles.selectedToggleButtonTextStyle
                  : MyStyles.unselectedToggleButtonTextStyle,
            ),
          ),
          Text(
            '1Y',
            style: _toggleButtonButtonsTime[4]
                ? MyStyles.selectedToggleButtonTextStyle
                : MyStyles.unselectedToggleButtonTextStyle,
          ),
        ],
        isSelected: _toggleButtonButtonsTime);
  }
}
