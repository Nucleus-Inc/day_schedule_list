import 'package:flutter/material.dart';

import '../helpers/time_of_day_extensions.dart';

///It represents a time interval inside your day schedule.
///
///Use it to create instances of unavailable intervals inside your daily
///schedule, extends it and add new variables to make it easy to map to your
///models that represent some appointment.
class IntervalRange {
  IntervalRange({
    required this.start,
    required this.end,
  }) : assert(start < end, 'start must be < end');

  ///The start time of day of time interval.
  ///
  ///* It must be < than [end]
  TimeOfDay start;

  ///The end time of day of time interval.
  ///
  ///* It must be > than [start]
  TimeOfDay end;

  ///Verify if [time] belongs to this time interval.
  bool containsTimeOfDay(TimeOfDay time, {bool closedRange = true}) {
    return closedRange ? start <= time && end >= time : start < time && end > time;
  }

  ///Verify if some time interval [range] intersects this one.
  bool intersects(IntervalRange range, {bool closedRange = false}) {
    return containsTimeOfDay(range.start, closedRange: closedRange) ||
        containsTimeOfDay(range.end, closedRange: closedRange) ||
        range.containsTimeOfDay(start, closedRange: closedRange) ||
        range.containsTimeOfDay(end, closedRange: closedRange) ||
        this == range;
  }

  ///Returns the time interval between [start] and [end] in minutes.
  int get deltaIntervalIMinutes => end.toMinutes - start.toMinutes;

  @override
  bool operator ==(Object other) {
    if(other is IntervalRange) {
      final range = other as IntervalRange;
      return range.start == start && range.end == end;
    }
    return false;
  }

  @override
  String toString() {
    return 'start: ${start.toString()} - end:${end.toString()}';
  }
}
