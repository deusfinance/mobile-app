import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  FirebaseAnalytics get analytics => _analytics;
  late FirebaseAnalyticsObserver observer;

  AnalyticsService() : this._analytics = FirebaseAnalytics() {
    observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }
}
