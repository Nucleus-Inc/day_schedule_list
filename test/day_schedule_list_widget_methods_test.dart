import 'package:day_schedule_list/src/models/interval_range.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget_extensions.dart';
import 'package:day_schedule_list/src/ui/dynamic_height_container.dart';
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
  _convertDeltaYToMinutesTest();
  _canUpdateHeightOfIntervalFromBottomTest();
  _canUpdateHeightOfIntervalFromTopTest();
  _canUpdatePositionOfIntervalTest();
  _populateValidTimesListTest();
  _calculateItervalRangeForNewPositionTest();
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
        methods.calculateItervalRangeForNewHeight(
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
        methods.calculateItervalRangeForNewHeight(
            start: time, newDurationHeight: methods.hourHeight * 30),
        predicate<IntervalRange>((result) {
          return result.start == time &&
              result.end == const TimeOfDay(hour: 23, minute: 59);
        }),
      );
    });
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

void _canUpdateHeightOfIntervalFromBottomTest() {
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
  group('.canUpdateHeightOfInterval()', () {
    test('try to update without intersections', () {
      expect(
          methods.canUpdateHeightOfInterval(
            from: HeightUpdateFrom.bottom,
            insetVertical: insetVertical,
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
            from: HeightUpdateFrom.bottom,
            insetVertical: insetVertical,
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

void _canUpdateHeightOfIntervalFromTopTest() {
  const insetVertical = 10.0;
  final methods = _DayScheduleListWidgetMethodsTest();
  final List<IntervalRange> appointments = [
    IntervalRange(
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 11, minute: 59),
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
            from: HeightUpdateFrom.top,
            insetVertical: insetVertical,
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
            from: HeightUpdateFrom.top,
            insetVertical: insetVertical,
            index: 1,
            appointments: appointments,
            unavailableIntervals: unavailableItems,
            newHeight: 450,
            validTimesList: validTimes,
          ),
          false);
    });
  });
}

void _canUpdatePositionOfIntervalTest() {
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

  const oneHourHeight = 100.0;
  const availableTimeIntervalInMinutes = 12 + 59/60.0;
  const contentHeight = availableTimeIntervalInMinutes * oneHourHeight;

  final validTimes =
      methods.populateValidTimesList(unavailableIntervals: unavailableItems);
  group('.canUpdatePositionOfInterval()', () {
    test('update appointment to valid interval', () {
      final newAppointmentInterval = IntervalRange(
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 11, minute: 0),
      );
      final newPosition = methods.calculateItemRangePosition(
        itemRange: newAppointmentInterval,
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
          methods.canUpdatePositionOfInterval(
            index: 0,
            appointments: appointments,
            newPosition: newPosition,
            insetVertical: insetVertical,
            contentHeight: contentHeight,
          ),
          true);
    });
    test('update appointment start time to less than min possible one', () {
      final newAppointmentInterval = IntervalRange(
        start: const TimeOfDay(hour: 7, minute: 59),
        end: const TimeOfDay(hour: 9, minute: 59),
      );
      final newPosition = methods.calculateItemRangePosition(
        itemRange: newAppointmentInterval,
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
          methods.canUpdatePositionOfInterval(
            index: 0,
            appointments: appointments,
            newPosition: newPosition,
            insetVertical: insetVertical,
            contentHeight: contentHeight,
          ),
          false);
    });
    test('update appointment end time to bigger than max possible one', () {
      final newAppointmentInterval = IntervalRange(
        start: const TimeOfDay(hour: 21, minute: 1),
        end: const TimeOfDay(hour: 23, minute: 59),
      );
      final newPosition = methods.calculateItemRangePosition(
        itemRange: newAppointmentInterval,
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
          methods.canUpdatePositionOfInterval(
            index: 3,
            appointments: appointments,
            newPosition: newPosition,
            insetVertical: insetVertical,
            contentHeight: contentHeight,
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
            result.last.time == const TimeOfDay(hour: 20, minute: 59);
      }),
    );
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
          methods.calculateItervalRangeForNewPosition(
            range: originalAppointment,
            newPosition: newPosition,
            firstValidTime: validTimes.first,
            insetVertical: insetVertical,
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
        methods.calculateItervalRangeForNewPosition(
          range: originalAppointment,
          newPosition: newPosition,
          firstValidTime: validTimes.first,
          insetVertical: insetVertical,
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
        methods.calculateItervalRangeForNewPosition(
          range: originalAppointment,
          newPosition: newPosition,
          firstValidTime: validTimes.first,
          insetVertical: insetVertical,
        ),
        predicate<IntervalRange>((result) =>
            updatedRange.start == result.start &&
            updatedRange.end == result.end),
      );
    });
  });
}

class _DayScheduleListWidgetMethodsTest with DayScheduleListWidgetMethods {
  _DayScheduleListWidgetMethodsTest();
  @override
  double get hourHeight => 100;
}
