import 'package:day_schedule_list/src/models/interval_range.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget_mixin.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:day_schedule_list/src/helpers/time_of_day_extensions.dart';
import 'package:day_schedule_list/src/models/minute_interval.dart';

void main() {
  _intersectsOtherIntervalTest();
  _belongsToInternalUnavailableRangeTest();
  _calculateItemRangePositionTest();
  _canUpdateHeightOfIntervalFromBottomTest();
  _canUpdateHeightOfIntervalFromTopTest();
  _canUpdatePositionOfIntervalTest();
  _populateValidTimesListTest();
  _buildInternalUnavailableIntervalsTest();
  _newAppointmentForTappedPositionTest();
  _timeOfDayWidgetHeightTest();
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
      ),
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
        true,
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


void _canUpdateHeightOfIntervalFromBottomTest() {
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
            mode: AppointmentUpdateMode.durationFromBottom,
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
            mode: AppointmentUpdateMode.durationFromBottom,
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
            mode: AppointmentUpdateMode.durationFromTop,
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
            mode: AppointmentUpdateMode.durationFromTop,
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
  final List<IntervalRange> unavailableItems = [
    IntervalRange(
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 8, minute: 0),
    ),
    IntervalRange(
      start: const TimeOfDay(hour: 21, minute: 0),
      end: const TimeOfDay(hour: 23, minute: 59),
    )
  ];

  const oneHourHeight = 100.0;
  const availableTimeIntervalInMinutes = 12 + 59 / 60.0;
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
            newPosition: newPosition,
            insetVertical: insetVertical,
            contentHeight: contentHeight,
          ),
          true);
    });
    test('update appointment start time to less than min possible one', () {
      final newAppointmentInterval = IntervalRange(
        start: const TimeOfDay(hour: 7, minute: 58),
        end: const TimeOfDay(hour: 9, minute: 59),
      );
      final newPosition = methods.calculateItemRangePosition(
        itemRange: newAppointmentInterval,
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
          methods.canUpdatePositionOfInterval(
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
        return result.first.time == const TimeOfDay(hour: 7, minute: 59) &&
            result.last.time == const TimeOfDay(hour: 21, minute: 0);
      }),
    );
  });
}

void _buildInternalUnavailableIntervalsTest() {
  group('.buildInternalUnavailableIntervals()', () {
    final methods = _DayScheduleListWidgetMethodsTest();
    test(
        'A list with more than 2 elements one with start at 00:00 and other with end at 23:59',
        () {
      final unavailableIntervals = [
        IntervalRange(
            start: const TimeOfDay(hour: 0, minute: 0),
            end: const TimeOfDay(hour: 8, minute: 0)),
        IntervalRange(
            start: const TimeOfDay(hour: 12, minute: 0),
            end: const TimeOfDay(hour: 13, minute: 0)),
        IntervalRange(
            start: const TimeOfDay(hour: 16, minute: 0),
            end: const TimeOfDay(hour: 16, minute: 30)),
        IntervalRange(
            start: const TimeOfDay(hour: 18, minute: 0),
            end: const TimeOfDay(hour: 23, minute: 59)),
      ];
      final expectedIntervals = unavailableIntervals.sublist(1, 3);
      expect(
        methods.buildInternalUnavailableIntervals(
            unavailableIntervals: unavailableIntervals),
        expectedIntervals,
      );
    });
    test(
        'A list with 2 elements one with start at 00:00 and other with end at 23:59',
        () {
      final unavailableIntervals = [
        IntervalRange(
            start: const TimeOfDay(hour: 0, minute: 0),
            end: const TimeOfDay(hour: 8, minute: 0)),
        IntervalRange(
            start: const TimeOfDay(hour: 18, minute: 0),
            end: const TimeOfDay(hour: 23, minute: 59)),
      ];
      final expectedIntervals = [];
      expect(
        methods.buildInternalUnavailableIntervals(
            unavailableIntervals: unavailableIntervals),
        expectedIntervals,
      );
    });
    test(
        'A list with more than 2 elements one with start at 00:00 and no one at 23:59',
        () {
      final unavailableIntervals = [
        IntervalRange(
            start: const TimeOfDay(hour: 0, minute: 0),
            end: const TimeOfDay(hour: 8, minute: 0)),
        IntervalRange(
            start: const TimeOfDay(hour: 12, minute: 0),
            end: const TimeOfDay(hour: 13, minute: 0)),
        IntervalRange(
            start: const TimeOfDay(hour: 16, minute: 0),
            end: const TimeOfDay(hour: 16, minute: 30)),
        IntervalRange(
            start: const TimeOfDay(hour: 18, minute: 0),
            end: const TimeOfDay(hour: 22, minute: 30)),
      ];
      final expectedIntervals = [
        unavailableIntervals[1],
        unavailableIntervals[2],
        unavailableIntervals[3]
      ];
      expect(
        methods.buildInternalUnavailableIntervals(
            unavailableIntervals: unavailableIntervals),
        expectedIntervals,
      );
    });
    test('an empty list', () {
      final List<IntervalRange> unavailableIntervals = [];
      expect(
        methods.buildInternalUnavailableIntervals(
            unavailableIntervals: unavailableIntervals),
        [],
      );
    });
    test('A list with less than 2 elements one with start at 00:00', () {
      final unavailableIntervals = [
        IntervalRange(
            start: const TimeOfDay(hour: 0, minute: 0),
            end: const TimeOfDay(hour: 8, minute: 0)),
      ];
      final expectedIntervals = [];
      expect(
        methods.buildInternalUnavailableIntervals(
            unavailableIntervals: unavailableIntervals),
        expectedIntervals,
      );
    });
    test('A list with less than 2 elements no one with start at 00:00 or 23:59',
        () {
      final unavailableIntervals = [
        IntervalRange(
          start: const TimeOfDay(hour: 8, minute: 0),
          end: const TimeOfDay(hour: 11, minute: 25),
        ),
      ];
      final expectedIntervals = [...unavailableIntervals];
      expect(
        methods.buildInternalUnavailableIntervals(
            unavailableIntervals: unavailableIntervals),
        expectedIntervals,
      );
    });
  });
}

void _newAppointmentForTappedPositionTest() {
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

  final List<IntervalRange> unavailableIntervals = [
    IntervalRange(
      start: const TimeOfDay(hour: 6, minute: 0),
      end: const TimeOfDay(hour: 7, minute: 59),
    ),
    IntervalRange(
      start: const TimeOfDay(hour: 21, minute: 0),
      end: const TimeOfDay(hour: 22, minute: 59),
    )
  ];
  const insetVertical = 10.0;

  final validTimes = methods.populateValidTimesList(
      unavailableIntervals: unavailableIntervals);

  group('.newAppointmentForTappedPosition()', () {
    final methods = _DayScheduleListWidgetMethodsTest();
    test('Add appointment inside time interval without intersections', () {
      final position = methods.calculateItemRangePosition(
        itemRange: appointments[0],
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
        methods.newAppointmentForTappedPosition(
            appointments: appointments,
            startPosition: Offset(
                0,
                position.top +
                    position.height +
                    methods.minimumMinuteIntervalHeight * 30),
            firstValidTimeList: validTimes.first,
            lastValidTimeList: validTimes.last,
            unavailableIntervals: unavailableIntervals),
        predicate<IntervalRange>((result) {
          return result.start == const TimeOfDay(hour: 10, minute: 6) &&
              result.end == const TimeOfDay(hour: 11, minute: 6);
        }),
      );
    });

    test('Add appointment inside time interval with intersections on start',
        () {
      final position = methods.calculateItemRangePosition(
        itemRange: appointments[0],
        insetVertical: insetVertical,
        firstValidTime: validTimes.first,
      );
      expect(
        methods.newAppointmentForTappedPosition(
            appointments: appointments,
            startPosition: Offset(
                0,
                position.top +
                    position.height
            ),
            firstValidTimeList: validTimes.first,
            lastValidTimeList: validTimes.last,
            unavailableIntervals: unavailableIntervals),
        predicate<IntervalRange>((result) {
          return result.start == const TimeOfDay(hour: 10, minute: 0) &&
              result.end == const TimeOfDay(hour: 10, minute: 36);
        }),
      );
    });

    test('Add appointment inside time interval with intersections on end',
            () {
          final position = methods.calculateItemRangePosition(
            itemRange: appointments[1],
            insetVertical: insetVertical,
            firstValidTime: validTimes.first,
          );
          expect(
            methods.newAppointmentForTappedPosition(
                appointments: appointments,
                startPosition: Offset(
                    0,
                    position.top - methods.minimumMinuteIntervalHeight,
                ),
                firstValidTimeList: validTimes.first,
                lastValidTimeList: validTimes.last,
                unavailableIntervals: unavailableIntervals),
            predicate<IntervalRange>((result) {
              return result.start == const TimeOfDay(hour: 11, minute: 35) &&
                  result.end == const TimeOfDay(hour: 12, minute: 0);
            }),
          );
        });

    test('Add appointment inside time interval constrained by min valid time',
            () {
          final position = methods.calculateItemRangePosition(
            itemRange: unavailableIntervals[0],
            insetVertical: insetVertical,
            firstValidTime: validTimes.first,
          );
          expect(
            methods.newAppointmentForTappedPosition(
                appointments: appointments,
                startPosition: Offset(
                  0,
                  position.top - methods.minimumMinuteIntervalHeight*60*7,
                ),
                firstValidTimeList: validTimes.first,
                lastValidTimeList: validTimes.last,
                unavailableIntervals: unavailableIntervals),
            predicate<IntervalRange>((result) {
              return result.start == const TimeOfDay(hour: 0, minute: 0) &&
                  result.end == const TimeOfDay(hour: 1, minute: 0);
            }),
          );
        });

    test('Add appointment inside time interval constrained by max valid time',
            () {
          final position = methods.calculateItemRangePosition(
            itemRange: unavailableIntervals.last,
            insetVertical: insetVertical,
            firstValidTime: validTimes.first,
          );
          expect(
            methods.newAppointmentForTappedPosition(
                appointments: appointments,
                startPosition: Offset(
                  0,
                  position.top + position.height + methods.minimumMinuteIntervalHeight*59,
                ),
                firstValidTimeList: validTimes.first,
                lastValidTimeList: validTimes.last,
                unavailableIntervals: unavailableIntervals),
            predicate<IntervalRange>((result) {
              return result.start == const TimeOfDay(hour: 23, minute: 34) &&
                  result.end == const TimeOfDay(hour: 23, minute: 59);
            }),
          );
        });
  });
}

void _timeOfDayWidgetHeightTest(){
  group('DayScheduleListWidgetMethods.timeOfDayWidgetHeight tests', (){
    test('Default data', (){
      final instance = _DayScheduleListWidgetMethodsTest();
      expect(instance.timeOfDayWidgetHeight, (instance.hourHeight*instance.minimumMinuteInterval.numberValue/60.0)*10);
    });
    test('minimumMinuteInterval = MinuteInterval.five', (){
      final instance = _DayScheduleListWidgetMethodsTest2();
      expect(instance.timeOfDayWidgetHeight, 17);
    });
    test('minimumMinuteInterval = MinuteInterval.ten', (){
      final instance = _DayScheduleListWidgetMethodsTest3();
      expect(instance.timeOfDayWidgetHeight, 17);
    });
    test('minimumMinuteInterval = MinuteInterval.fifteen', (){
      final instance = _DayScheduleListWidgetMethodsTest4();
      expect(instance.timeOfDayWidgetHeight, 17);
    });
  });
}

class _DayScheduleListWidgetMethodsTest with DayScheduleListWidgetMixin {
  _DayScheduleListWidgetMethodsTest();
  @override
  double get hourHeight => 100;
}

class _DayScheduleListWidgetMethodsTest2 with DayScheduleListWidgetMixin {
  _DayScheduleListWidgetMethodsTest2();
  @override
  double get hourHeight => 100;
  @override
  MinuteInterval get minimumMinuteInterval => MinuteInterval.five;
  @override
  MinuteInterval get appointmentMinimumDuration => MinuteInterval.thirty;
}

class _DayScheduleListWidgetMethodsTest3 with DayScheduleListWidgetMixin {
  _DayScheduleListWidgetMethodsTest3();
  @override
  double get hourHeight => 100;
  @override
  MinuteInterval get minimumMinuteInterval => MinuteInterval.ten;
  @override
  MinuteInterval get appointmentMinimumDuration => MinuteInterval.thirty;
}

class _DayScheduleListWidgetMethodsTest4 with DayScheduleListWidgetMixin {
  _DayScheduleListWidgetMethodsTest4();
  @override
  double get hourHeight => 100;
  @override
  MinuteInterval get minimumMinuteInterval => MinuteInterval.fifteen;
  @override
  MinuteInterval get appointmentMinimumDuration => MinuteInterval.thirty;
}