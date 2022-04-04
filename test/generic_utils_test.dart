import 'package:day_schedule_list/src/helpers/generic_utils.dart';
import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget_mixin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _calculateTimeOfDayIndicatorsInsetTest();
  _convertDeltaYToMinutesTest();
  calculateCloserMinutesThatIsMultipleOfMinimumMinuteIntervalTest();
}

void _calculateTimeOfDayIndicatorsInsetTest() {
  test('.calculateTimeOfDayIndicatorsInset() verify returns correct value', () {
    const timeOfDayWidgetHeight = 20.0;
    expect(
      GenericUtils.calculateTimeOfDayIndicatorsInset(timeOfDayWidgetHeight),
      equals(10.0),
    );
  });
}

void _convertDeltaYToMinutesTest() {
  final methods = _DayScheduleListWidgetMethodsTest();
  group('.convertDeltaYToMinutes()', () {
    test('verify result for y axis variation of 120', () {
      expect(
        GenericUtils.convertDeltaYToMinutes(
          deltaY: 120,
          minimumMinuteInterval: methods.minimumMinuteInterval,
          minimumMinuteIntervalHeight: methods.minimumMinuteIntervalHeight,
        ),
        equals(72),
      );
    });
    test('verify result for y axis variation of 0.5', () {
      expect(
        GenericUtils.convertDeltaYToMinutes(
          deltaY: 0.5,
          minimumMinuteInterval: methods.minimumMinuteInterval,
          minimumMinuteIntervalHeight: methods.minimumMinuteIntervalHeight,
        ),
        equals(0, 3),
      );
    });
  });
}

void calculateCloserMinutesThatIsMultipleOfMinimumMinuteIntervalTest(){
  final methods = _DayScheduleListWidgetMethodsTest();
  group('.calculateCloserMinutesThatIsMultipleOfMinimumMinuteInterval()', () {
    test('verify result for minutes 30 and minimum minutes interval ${MinuteInterval.fifteen.numberValue}', () {
      expect(
        GenericUtils.calculateCloserMinutesThatIsMultipleOfMinimumMinuteInterval(
          minutes: 30,
          minimumMinuteInterval: methods.minimumMinuteInterval,
        ),
        equals(30),
      );
    });
    test('verify result for minutes 35 and minimum minutes interval ${MinuteInterval.fifteen.numberValue}', () {
      expect(
        GenericUtils.calculateCloserMinutesThatIsMultipleOfMinimumMinuteInterval(
          minutes: 35,
          minimumMinuteInterval: methods.minimumMinuteInterval,
        ),
        equals(30),
      );
    });
    test('verify result for minutes 3 and minimum minutes interval ${MinuteInterval.fifteen.numberValue}', () {
      expect(
        GenericUtils.calculateCloserMinutesThatIsMultipleOfMinimumMinuteInterval(
          minutes: 3,
          minimumMinuteInterval: methods.minimumMinuteInterval,
        ),
        equals(0),
      );
    });
  });
}

class _DayScheduleListWidgetMethodsTest with DayScheduleListWidgetMixin {
  _DayScheduleListWidgetMethodsTest();
  @override
  double get hourHeight => 100;
  @override
  MinuteInterval get minimumMinuteInterval => MinuteInterval.fifteen;
}