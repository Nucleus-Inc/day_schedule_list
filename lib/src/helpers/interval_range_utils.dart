import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/helpers/generic_utils.dart';
import 'package:day_schedule_list/src/helpers/time_of_day_extensions.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:flutter/material.dart';

class IntervalRangeUtils {
  static IntervalRange calculateItervalRangeForNewPosition({
    required IntervalRange range,
    required ScheduleItemPosition newPosition,
    required ScheduleTimeOfDay firstValidTime,
    required double insetVertical,
    required MinuteInterval minimumMinuteInterval,
    required double minimumMinuteIntervalHeight,
  }) {
    final start = range.start;
    final end = range.end;
    final int newStartIncrement =
        firstValidTime.time.hour > 0 || firstValidTime.time.minute > 0
            ? firstValidTime.time.toMinutes
            : 0;
    final int newStartInMinutes = GenericUtils.convertDeltaYToMinutes(
            deltaY: newPosition.top - insetVertical,
            minimumMinuteInterval: minimumMinuteInterval,
            minimumMinuteIntervalHeight: minimumMinuteIntervalHeight) +
        newStartIncrement;

    final int newEndInMinutes = GenericUtils.convertDeltaYToMinutes(
            deltaY: newPosition.top + newPosition.height - insetVertical,
            minimumMinuteInterval: minimumMinuteInterval,
            minimumMinuteIntervalHeight: minimumMinuteIntervalHeight) +
        newStartIncrement;

    final startDeltaInMinutes = newStartInMinutes - start.toMinutes;
    final endDeltaInMinutes = newEndInMinutes - end.toMinutes;

    final DateTime startDateTime = DateTime(
      DateTime.now().year,
      1,
      1,
      start.hour,
      start.minute,
    ).add(Duration(minutes: startDeltaInMinutes));
    final TimeOfDay newStart = TimeOfDay.fromDateTime(startDateTime);

    final DateTime endDateTime = DateTime(
      DateTime.now().year,
      1,
      1,
      end.hour,
      end.minute,
    ).add(Duration(minutes: endDeltaInMinutes));
    final TimeOfDay newEnd = TimeOfDay.fromDateTime(endDateTime);

    if (newStart < newEnd) {
      return IntervalRange(start: newStart, end: newEnd);
    }
    return IntervalRange(start: start, end: end);
  }

  static IntervalRange calculateItervalRangeForNewHeight({
    required TimeOfDay start,
    required double newDurationHeight,
    required MinuteInterval minimumMinuteInterval,
    required double minimumMinuteIntervalHeight,
  }) {
    final int durationInMinutes = GenericUtils.convertDeltaYToMinutes(
      deltaY: newDurationHeight,
      minimumMinuteInterval: minimumMinuteInterval,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
    );
    final DateTime endDateTime = DateTime(
      DateTime.now().year,
      1,
      1,
      start.hour,
      start.minute,
    ).add(Duration(minutes: durationInMinutes));
    TimeOfDay end;
    end = endDateTime.day != 1
        ? const TimeOfDay(hour: 23, minute: 59)
        : TimeOfDay.fromDateTime(endDateTime);
    return IntervalRange(
      start: start,
      end: end,
    );
  }

  static IntervalRange calculateItervalRangeForNewHeightFromTop({
    required TimeOfDay end,
    required double newDurationHeight,
    required MinuteInterval minimumMinuteInterval,
    required double minimumMinuteIntervalHeight,
  }) {
    final int durationInMinutes = GenericUtils.convertDeltaYToMinutes(
      deltaY: newDurationHeight,
      minimumMinuteInterval: minimumMinuteInterval,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
    );
    final DateTime startDateTime = DateTime(
      DateTime.now().year,
      1,
      1,
      end.hour,
      end.minute,
    ).subtract(
      Duration(minutes: durationInMinutes),
    );
    TimeOfDay newStart;
    newStart = startDateTime.day != 1
        ? const TimeOfDay(hour: 0, minute: 0)
        : TimeOfDay.fromDateTime(startDateTime);
    return IntervalRange(start: newStart, end: end);
  }
}
