import 'package:day_schedule_list/src/models/minute_interval.dart';

class GenericUtils {
  static int convertDeltaYToMinutes({
    required double deltaY,
    required MinuteInterval minimumMinuteInterval,
    required double minimumMinuteIntervalHeight,
  }) {
    return ((deltaY * minimumMinuteInterval.numberValue) /
            minimumMinuteIntervalHeight)
        .round();
  }

  static double calculateTimeOfDayIndicatorsInset(
      double timeOfDayWidgetHeight) {
    return timeOfDayWidgetHeight / 2.0;
  }

  static int calculateCloserMinutesThatIsMultipleOfMinimumMinuteInterval({
    required int minutes,
    required MinuteInterval minimumMinuteInterval,
  }) {
    return (minutes ~/ minimumMinuteInterval.numberValue) *
        minimumMinuteInterval.numberValue;
  }
}
