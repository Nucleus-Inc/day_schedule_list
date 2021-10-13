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
  bool containsTimeOfDay(TimeOfDay time) {
    return start <= time && end >= time;
  }

  ///Verify if some time interval [range] intersects this one.
  bool intersects(IntervalRange range) {
    return containsTimeOfDay(range.start) || containsTimeOfDay(range.end) ||
        range.containsTimeOfDay(start) || range.containsTimeOfDay(end);
  }

  ///Returns the time interval between [start] and [end] in minutes.
  int get deltaIntervalIMinutes => end.toMinutes - start.toMinutes;
}
