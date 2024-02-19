import 'package:day_schedule_list/src/helpers/interval_range_utils.dart';
import 'package:day_schedule_list/src/models/interval_range.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _calculateItervalRangeForTest();
  _calculateItervalRangeForNewPositionTest();
}

void _calculateItervalRangeForTest() {
  group('.calculateItervalRangeFor()', () {
    final methods = _DayScheduleListWidgetMethodsTest();

    test(
        'verify IntervalRange result for some '
        'height duration', () {
      const time = TimeOfDay(
        hour: 10,
        minute: 30,
      );
      expect(
        IntervalRangeUtils.calculateItervalRangeForNewHeight(
          start: time,
          newDurationHeight: methods.hourHeight * 3,
          minimumMinuteIntervalHeight: methods.minimumMinuteIntervalHeight,
          minimumMinuteInterval: methods.minimumMinuteInterval,
        ),
        predicate<IntervalRange>((result) {
          return result.start == time &&
              result.deltaIntervalIMinutes == 3 * 60.0;
        }),
      );
    });
    test(
        'verify IntervalRange result for a height duration that makes it '
        'cross to next day', () {
      const time = TimeOfDay(
        hour: 10,
        minute: 30,
      );
      expect(
        IntervalRangeUtils.calculateItervalRangeForNewHeight(
          start: time,
          newDurationHeight: methods.hourHeight * 30,
          minimumMinuteIntervalHeight: methods.minimumMinuteIntervalHeight,
          minimumMinuteInterval: methods.minimumMinuteInterval,
        ),
        predicate<IntervalRange>((result) {
          return result.start == time &&
              result.end == const TimeOfDay(hour: 23, minute: 59);
        }),
      );
    });
  });
}

void _calculateItervalRangeForNewPositionTest() {
  const insetVertical = 10.0;
  final methods = _DayScheduleListWidgetMethodsTest();
  final List<IntervalRange> appointments = [
    IntervalRange(
      start: const TimeOfDay(hour: 8, minute: 0),
      end: const TimeOfDay(hour: 10, minute: 0),
    ),
    IntervalRange(
      start: const TimeOfDay(hour: 12, minute: 0),
      end: const TimeOfDay(hour: 14, minute: 35),
    ),
    IntervalRange(
      start: const TimeOfDay(hour: 16, minute: 0),
      end: const TimeOfDay(hour: 16, minute: 32),
    ),
    IntervalRange(
      start: const TimeOfDay(hour: 17, minute: 0),
      end: const TimeOfDay(hour: 20, minute: 30),
    )
  ];
  final List<IntervalRange> unavailableItems = [
    IntervalRange(
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 7, minute: 59),
    ),
    IntervalRange(
      start: const TimeOfDay(hour: 21, minute: 0),
      end: const TimeOfDay(hour: 23, minute: 59),
    )
  ];

  final validTimes =
  methods.populateValidTimesList(unavailableIntervals: unavailableItems);

  group('.calculateItervalRangeForNewPosition()', () {
    test('decrease appointment duration', () {
      final originalAppointment = appointments[0];
      final updatedRange = IntervalRange(
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 9, minute: 30),
      );
      final newPosition = methods.calculateItemRangePosition(
        itemRange: updatedRange,
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
          IntervalRangeUtils.calculateIntervalRangeForNewPosition(
            range: originalAppointment,
            newPosition: newPosition,
            firstValidTime: validTimes.first,
            insetVertical: insetVertical,
            minimumMinuteIntervalHeight: methods.minimumMinuteIntervalHeight,
            minimumMinuteInterval: methods.minimumMinuteInterval,
          ),
          predicate<IntervalRange>((result) =>
          updatedRange.start == result.start &&
              updatedRange.end == result.end));
    });
    test('increase appointment duration', () {
      final originalAppointment = appointments[1];
      final updatedRange = IntervalRange(
        start: const TimeOfDay(hour: 12, minute: 0),
        end: const TimeOfDay(hour: 16, minute: 35),
      );
      final newPosition = methods.calculateItemRangePosition(
        itemRange: updatedRange,
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
        IntervalRangeUtils.calculateIntervalRangeForNewPosition(
          range: originalAppointment,
          newPosition: newPosition,
          firstValidTime: validTimes.first,
          insetVertical: insetVertical,
          minimumMinuteIntervalHeight: methods.minimumMinuteIntervalHeight,
          minimumMinuteInterval: methods.minimumMinuteInterval,
        ),
        predicate<IntervalRange>((result) =>
        updatedRange.start == result.start &&
            updatedRange.end == result.end),
      );
    });
    test('maintain duration and change start date', () {
      final originalAppointment = appointments[2];
      final updatedRange = IntervalRange(
        start: const TimeOfDay(hour: 17, minute: 0),
        end: const TimeOfDay(hour: 17, minute: 32),
      );
      final newPosition = methods.calculateItemRangePosition(
        itemRange: updatedRange,
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
        IntervalRangeUtils.calculateIntervalRangeForNewPosition(
          range: originalAppointment,
          newPosition: newPosition,
          firstValidTime: validTimes.first,
          insetVertical: insetVertical,
          minimumMinuteIntervalHeight: methods.minimumMinuteIntervalHeight,
          minimumMinuteInterval: methods.minimumMinuteInterval,
        ),
        predicate<IntervalRange>((result) =>
        updatedRange.start == result.start &&
            updatedRange.end == result.end),
      );
    });
  });
}



class _DayScheduleListWidgetMethodsTest with DayScheduleListWidgetMixin {
  _DayScheduleListWidgetMethodsTest();
  @override
  double get hourHeight => 100;
}
