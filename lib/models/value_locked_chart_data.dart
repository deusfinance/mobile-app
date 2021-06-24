import 'package:deus_mobile/models/chart_data_point.dart';

class ValueLockedChartData {
  final double? relativeChange;
  final double? absoluteChange;
  final double? lockedInCash;
  final double? lockedInCrypto;
  final List<ChartDataPoint>? chartDataPoints;

  ValueLockedChartData(
      {this.relativeChange,
      this.absoluteChange,
      this.lockedInCash,
      this.lockedInCrypto,
      this.chartDataPoints});
}
