import '../../models/chart_data_point.dart';
import '../../statics/my_colors.dart';
import '../../statics/styles.dart';
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
  // late Future<List<ChartDataPoint>> _futureData;

  /// List which shows which ToggleButton is selected
  List<bool> _toggleButtonButtonsTime = [false, false, true, false, false];
  static const SizedBox _bigHeightDivider = SizedBox(height: 20);

  List<FlSpot> _generateList(List<ChartDataPoint> values) {
    final List<FlSpot> reList = [];
    for (double i = 0; i < values.length; i++) {
      reList.add(FlSpot(i, values[i.toInt()].value));
    }
    return reList;
  }

  void _changeToggleButtonTime(int i) {
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
                    spots: _generateList(widget.dataPoints),
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
          _changeToggleButtonTime(ind);
          switch (ind) {
            case 0:
              timePressed(const Duration(hours: 1));

              break;
            case 1:
              timePressed(const Duration(days: 1));
              break;
            case 2:
              timePressed(const Duration(days: 7));

              break;
            case 3:
              timePressed(
                const Duration(days: 30),
              );

              break;
            case 4:
              timePressed(const Duration(days: 365));
              break;
          }
        },
        children: [
          _buildButtonText(
              label: '1H',
              padding: true,
              isSelected: _toggleButtonButtonsTime[0]),
          _buildButtonText(
              label: '1D',
              padding: true,
              isSelected: _toggleButtonButtonsTime[1]),
          _buildButtonText(
              label: '1W',
              padding: true,
              isSelected: _toggleButtonButtonsTime[2]),
          _buildButtonText(
              label: '1M',
              padding: true,
              isSelected: _toggleButtonButtonsTime[3]),
          _buildButtonText(
              label: '1Y',
              padding: false,
              isSelected: _toggleButtonButtonsTime[4]),
        ],
        isSelected: _toggleButtonButtonsTime);
  }

  Padding _buildButtonText({String? label, bool? isSelected, bool? padding}) {
    return Padding(
      padding: padding! ? const EdgeInsets.only(right: 30) : EdgeInsets.zero,
      child: Text(
        label!,
        style: isSelected!
            ? MyStyles.selectedToggleButtonTextStyle
            : MyStyles.unselectedToggleButtonTextStyle,
      ),
    );
  }

  void timePressed(Duration dur) {
    setState(() {
      widget.onTimeSelected(dur);
    });
  }
}
