import 'package:deus_mobile/models/chart_data_point.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomChart extends StatefulWidget {
  final List<ChartDataPoint> dataPoints;
  final void Function(Duration pastDuration) onTimeSelected;

  CustomChart(this.dataPoints, this.onTimeSelected);

  @override
  _CustomChartState createState() => _CustomChartState();
}

class _CustomChartState extends State<CustomChart> {
  Future<List<ChartDataPoint>> futureData;

  List<FlSpot> generateList(List<ChartDataPoint> values) {
    List<FlSpot> reList = [];
    double counter = 0;
    values.forEach((elem) {
      reList.add(FlSpot(counter, elem.value));
      counter++;
    });
    return reList;
  }

  SizedBox _bigHeightDivider = SizedBox(
    height: 20,
  );

  List<bool> _toggleButtonButtonsTime = [false, false, true, false, false];

  void changeToggleButtonTime(int i) {
    if (!_toggleButtonButtonsTime[i]) {
      _toggleButtonButtonsTime = [false, false, false, false, false];
      setState(() {
        _toggleButtonButtonsTime[i] = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 150,
            width: double.infinity,
            child: LineChart(LineChartData(
                minY: 0,
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                axisTitleData: FlAxisTitleData(show: false),
                gridData: FlGridData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    colors: [MyColors.ToastGreen],
                    spots: generateList(widget.dataPoints),
                    isCurved: false,
                    dotData: FlDotData(show: false),
                  )
                ]))),
        _bigHeightDivider,
        _buildToggleButtons()
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
              timePressed(Duration(hours: 1));

              break;
            case 1:
              timePressed(Duration(days: 1));
              break;
            case 2:
              timePressed(Duration(days: 7));

              break;
            case 3:
              timePressed(
                Duration(days: 30),
              );

              break;
            case 4:
              timePressed(Duration(days: 365));
              break;
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

  void timePressed(Duration dur) {
    setState(() {
      widget.onTimeSelected(dur);
    });
  }
}
