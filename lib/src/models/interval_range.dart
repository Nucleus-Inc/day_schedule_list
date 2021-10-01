import 'package:flutter/material.dart';

import '../helpers/time_of_day_extensions.dart';

class IntervalRange {
  IntervalRange({
    required this.start,
    required this.end,
  }) : assert(start < end, 'start must be < end');
  TimeOfDay start;
  TimeOfDay end;

  bool belongsToRange(TimeOfDay time) {
    return start <= time && end >= time;
  }

  bool intersects(IntervalRange range) {
    return belongsToRange(range.start) || belongsToRange(range.end);
  }

  int get deltaIntervalIMinutes => end.toMinutes - start.toMinutes;
}
