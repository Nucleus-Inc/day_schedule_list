import 'package:day_schedule_list/src/helpers/schedule_item_position_utils.dart';
import 'package:day_schedule_list/src/helpers/time_of_day_extensions.dart';
import 'package:day_schedule_list/src/models/interval_range.dart';
import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget_mixin.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  calculateItemRangePositionTest();
  calculateOffsetIncrementTest();
}

void calculateItemRangePositionTest() {
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
          ScheduleItemPositionUtils.calculateItemRangePosition(
            itemRange: item,
            insetVertical: insetVertical,
            firstValidTime: firstValidTime,
            minimumMinuteIntervalHeight: methods.minimumMinuteIntervalHeight,
            minimumMinuteInterval: methods.minimumMinuteInterval,
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

void calculateOffsetIncrementTest() {
  group('.calculateOffsetIncrement()', () {
    test(
      'offset increment when antecipanting appointment',
      () {
        final oldPosition = ScheduleItemPosition(top: 100, height: 100);
        final newPosition = oldPosition.withNewTop(80);
        const updateMode = AppointmentUpdateMode.position;
        expect(
          ScheduleItemPositionUtils.calculateOffsetIncrement(
            oldPosition: oldPosition,
            newPosition: newPosition,
            updateMode: updateMode,
          ),
          -20,
        );
      },
    );
    test(
      'offset increment when postponing appointment',
          () {
        final oldPosition = ScheduleItemPosition(top: 100, height: 100);
        final newPosition = oldPosition.withNewTop(180);
        const updateMode = AppointmentUpdateMode.position;
        expect(
          ScheduleItemPositionUtils.calculateOffsetIncrement(
            oldPosition: oldPosition,
            newPosition: newPosition,
            updateMode: updateMode,
          ),
          80,
        );
      },
    );
    test(
      'offset increment when incrementing duration without changing start time',
          () {
        final oldPosition = ScheduleItemPosition(top: 100, height: 100);
        final newPosition = oldPosition.withNewHeight(120);
        const updateMode = AppointmentUpdateMode.durationFromBottom;
        expect(
          ScheduleItemPositionUtils.calculateOffsetIncrement(
            oldPosition: oldPosition,
            newPosition: newPosition,
            updateMode: updateMode,
          ),
          20,
        );
      },
    );
    test(
      'offset increment when decrementing duration without changing start time',
          () {
        final oldPosition = ScheduleItemPosition(top: 100, height: 100);
        final newPosition = oldPosition.withNewHeight(20);
        const updateMode = AppointmentUpdateMode.durationFromBottom;
        expect(
          ScheduleItemPositionUtils.calculateOffsetIncrement(
            oldPosition: oldPosition,
            newPosition: newPosition,
            updateMode: updateMode,
          ),
          -80,
        );
      },
    );
    test(
      'offset increment when decrementing duration without changing start time',
          () {
        final oldPosition = ScheduleItemPosition(top: 100, height: 100);
        final newPosition = ScheduleItemPosition(top: 60, height: 140);
        const updateMode = AppointmentUpdateMode.durationFromTop;
        expect(
          ScheduleItemPositionUtils.calculateOffsetIncrement(
            oldPosition: oldPosition,
            newPosition: newPosition,
            updateMode: updateMode,
          ),
          -40,
        );
      },
    );
  });
}

class _DayScheduleListWidgetMethodsTest with DayScheduleListWidgetMixin {
  _DayScheduleListWidgetMethodsTest();
  @override
  double get hourHeight => 100;
}
