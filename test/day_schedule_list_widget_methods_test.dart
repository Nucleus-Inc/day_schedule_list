import 'package:day_schedule_list/src/models/interval_range.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget_extensions.dart';
import 'package:day_schedule_list/src/ui/time_of_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:day_schedule_list/src/helpers/time_of_day_extensions.dart';
import 'package:day_schedule_list/src/models/minute_interval.dart';

void main() {
  _calculateTimeOfDayIndicatorsInsetTest();
  _intersectsOtherIntervalTest();
  _belongsToInternalUnavailableRangeTest();
  _calculateItemRangePositionTest();
  _calculateItervalRangeForTest();
  _calculateItervalRangeForNewTopTest();
  _calculateItervalRangeForNewTopTest();
  _convertDeltaYToMinutesTest();
  _canUpdateHeightOfIntervalTest();
  _canUpdateTopOfIntervalTest();
  _populateValidTimesListTest();
}

void _calculateTimeOfDayIndicatorsInsetTest() {
  test('.calculateTimeOfDayIndicatorsInset() verify returns correct value', () {
    const timeOfDayWidgetHeight = 20.0;
    final methods = _DayScheduleListWidgetMethodsTest();
    expect(
      methods.calculateTimeOfDayIndicatorsInset(timeOfDayWidgetHeight),
      equals(10.0),
    );
  });
}

void _intersectsOtherIntervalTest() {
  group('.intersectsOtherInterval()', () {
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

    test('verify some interval intersects interval', () {
      final IntervalRange newInterval = IntervalRange(
        start: const TimeOfDay(hour: 8, minute: 35),
        end: const TimeOfDay(hour: 11, minute: 20),
      );
      final methods = _DayScheduleListWidgetMethodsTest();
      expect(
        methods.intersectsOtherInterval(
          intervals: appointments,
          newInterval: newInterval,
        ),
        true,
      );
    });
    test('verify does not intersect interval', () {
      final IntervalRange newInterval = IntervalRange(
        start: const TimeOfDay(hour: 0, minute: 35),
        end: const TimeOfDay(hour: 7, minute: 59),
      );
      final methods = _DayScheduleListWidgetMethodsTest();
      expect(
        methods.intersectsOtherInterval(
          intervals: appointments,
          newInterval: newInterval,
        ),
        false,
      );
    });
  });
}

void _belongsToInternalUnavailableRangeTest() {
  group('.belongsToInternalUnavailableRange()', () {
    final List<IntervalRange> unavailableItems = [
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

    test('belongs to some interval', () {
      const time = TimeOfDay(hour: 12, minute: 30);
      final methods = _DayScheduleListWidgetMethodsTest();
      expect(
        methods.belongsToInternalUnavailableRange(
          time: time,
          unavailableIntervals: unavailableItems,
        ),
        true,
      );
    });

    test('does not belongs to any internal range', () {
      const time = TimeOfDay(hour: 15, minute: 0);
      final methods = _DayScheduleListWidgetMethodsTest();
      expect(
        methods.belongsToInternalUnavailableRange(
          time: time,
          unavailableIntervals: unavailableItems,
        ),
        false,
      );
    });

    test('belongs to some range but not to some of internal ones', () {
      const time = TimeOfDay(hour: 8, minute: 30);
      final methods = _DayScheduleListWidgetMethodsTest();
      expect(
        methods.belongsToInternalUnavailableRange(
          time: time,
          unavailableIntervals: unavailableItems,
        ),
        false,
      );
    });
  });
}

void _calculateItemRangePositionTest() {
  final methods = _DayScheduleListWidgetMethodsTest();
  const insetVertical = 10.0;
  final firstValidTime = ScheduleTimeOfDay.available(
    time: const TimeOfDay(
      hour: 8,
      minute: 40,
    ),
  );

  group('.calculateItemRangePosition()', () {
    test(
      'check the result for the earliest possible time interval',
      () {
        final item = IntervalRange(
          start: const TimeOfDay(hour: 8, minute: 40),
          end: const TimeOfDay(hour: 9, minute: 10),
        );
        expect(
          methods.calculateItemRangePosition(
            itemRange: item,
            insetVertical: insetVertical,
            firstValidTime: firstValidTime,
          ),
          predicate<ScheduleItemPosition>((result) {
            return result.top == insetVertical &&
                result.height == methods.hourHeight / 2.0;
          }),
        );
      },
    );
    test(
      'check the result for the latest possible time interval',
      () {
        final item = IntervalRange(
          start: const TimeOfDay(hour: 22, minute: 00),
          end: const TimeOfDay(hour: 23, minute: 59),
        );
        final deltaTop = item.start.toMinutes - firstValidTime.time.toMinutes;
        expect(
          methods.calculateItemRangePosition(
            itemRange: item,
            insetVertical: insetVertical,
            firstValidTime: firstValidTime,
          ),
          predicate<ScheduleItemPosition>((result) {
            return result.top ==
                    methods.minimumMinuteIntervalHeight *
                            (deltaTop /
                                methods.minimumMinuteInterval.numberValue) +
                        insetVertical &&
                result.height == methods.hourHeight * 119 / 60.0;
          }),
        );
      },
    );
  });
}

void _calculateItervalRangeForTest() {
  group('.calculateItervalRangeFor()', () {
    test(
        'verify IntervalRange result for some '
        'height duration', () {
      final methods = _DayScheduleListWidgetMethodsTest();
      const time = TimeOfDay(
        hour: 10,
        minute: 30,
      );
      expect(
        methods.calculateItervalRangeFor(
            start: time, newDurationHeight: methods.hourHeight * 3),
        predicate<IntervalRange>((result) {
          return result.start == time &&
              result.deltaIntervalIMinutes == 3 * 60.0;
        }),
      );
    });
    test(
        'verify IntervalRange result for a height duration that makes it '
        'cross to next day', () {
      final methods = _DayScheduleListWidgetMethodsTest();
      const time = TimeOfDay(
        hour: 10,
        minute: 30,
      );
      expect(
        methods.calculateItervalRangeFor(
            start: time, newDurationHeight: methods.hourHeight * 30),
        predicate<IntervalRange>((result) {
          return result.start == time &&
              result.end == const TimeOfDay(hour: 23, minute: 59);
        }),
      );
    });
  });
}

void _calculateItervalRangeForNewTopTest() {
  final methods = _DayScheduleListWidgetMethodsTest();
  const insetVertical = 10.0;
  const firstValidTime = TimeOfDay(
    hour: 8,
    minute: 40,
  );
  final range = IntervalRange(
    start: const TimeOfDay(hour: 10, minute: 0),
    end: const TimeOfDay(hour: 14, minute: 30),
  );

  group('.calculateItervalRangeForNewTop()', () {
    test(
      'Verify new IntervalRange for new top equal 10',
      () {
        expect(
          methods.calculateItervalRangeForNewTop(
            range: range,
            newTop: 10,
            firstValidTime: firstValidTime,
            insetVertical: insetVertical,
          ),
          predicate<IntervalRange>(
            (result) {
              return result.start == firstValidTime &&
                  result.deltaIntervalIMinutes == range.deltaIntervalIMinutes;
            },
          ),
        );
      },
    );
    test(
      'Verify new IntervalRange for new top equal 300',
      () {
        expect(
          methods.calculateItervalRangeForNewTop(
            range: range,
            newTop: 300,
            firstValidTime: firstValidTime,
            insetVertical: insetVertical,
          ),
          predicate<IntervalRange>(
            (result) {
              //174
              return result.start == const TimeOfDay(hour: 11, minute: 34) &&
                  result.deltaIntervalIMinutes == range.deltaIntervalIMinutes;
            },
          ),
        );
      },
    );
  });
}

void _convertDeltaYToMinutesTest() {
  final methods = _DayScheduleListWidgetMethodsTest();
  group('.convertDeltaYToMinutes()', () {
    test('verify result for y axis variation of 120', () {
      expect(
        methods.convertDeltaYToMinutes(
          deltaY: 120,
        ),
        equals(72),
      );
    });
    test('verify result for y axis variation of 0.5', () {
      expect(
        methods.convertDeltaYToMinutes(
          deltaY: 0.5,
        ),
        equals(0, 3),
      );
    });
  });
}

void _canUpdateHeightOfIntervalTest() {
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
  group('.canUpdateHeightOfInterval()', () {
    test('try to update without intersections', () {
      expect(
          methods.canUpdateHeightOfInterval(
            index: 0,
            appointments: appointments,
            unavailableIntervals: unavailableItems,
            newHeight: 200,
            validTimesList: validTimes,
          ),
          true);
    });
    test('try to update with intersections', () {
      expect(
          methods.canUpdateHeightOfInterval(
            index: 0,
            appointments: appointments,
            unavailableIntervals: unavailableItems,
            newHeight: 450,
            validTimesList: validTimes,
          ),
          false);
    });
  });
}

void _canUpdateTopOfIntervalTest() {
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
  final height = methods.hourHeight *
      ((validTimes.last.time.toMinutes - validTimes.first.time.toMinutes) /
          60.0);
  const insetVertical = 10.0;
  group('.canUpdateTopOfInterval()', () {
    test('try to update without intersections', () {
      expect(
          methods.canUpdateTopOfInterval(
            insetVertical: insetVertical,
            index: 0,
            appointments: appointments,
            newTop: 200,
            contentHeight: height,
            validTimesList: validTimes,
          ),
          true);
    });
    test('try to update to less than insetVertical', () {
      expect(
          methods.canUpdateTopOfInterval(
            insetVertical: insetVertical,
            index: 0,
            appointments: appointments,
            newTop: insetVertical / 2.0,
            contentHeight: height,
            validTimesList: validTimes,
          ),
          false);
    });
    test('try to update to bigger than content height', () {
      expect(
          methods.canUpdateTopOfInterval(
            insetVertical: insetVertical,
            index: 0,
            appointments: appointments,
            newTop: height,
            contentHeight: height,
            validTimesList: validTimes,
          ),
          false);
    });
  });
}

void _populateValidTimesListTest() {
  final methods = _DayScheduleListWidgetMethodsTest();

  final List<IntervalRange> unavailableItems = [
    IntervalRange(
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 7, minute: 59),
    ),
    IntervalRange(
      start: const TimeOfDay(hour: 12, minute: 0),
      end: const TimeOfDay(hour: 13, minute: 30),
    ),
    IntervalRange(
      start: const TimeOfDay(hour: 21, minute: 0),
      end: const TimeOfDay(hour: 23, minute: 59),
    )
  ];
  test('.populateValidTimesList()', () {
    expect(
      methods.populateValidTimesList(
        unavailableIntervals: unavailableItems,
      ),
      predicate<List<ScheduleTimeOfDay>>((result) {
        return result.first.time == const TimeOfDay(hour: 8, minute: 0) &&
          result.last.time == const TimeOfDay(hour:20, minute: 59);
      }),
    );
  });
}

class _DayScheduleListWidgetMethodsTest with DayScheduleListWidgetMethods {
  _DayScheduleListWidgetMethodsTest();
  @override
  double get hourHeight => 100;
}
