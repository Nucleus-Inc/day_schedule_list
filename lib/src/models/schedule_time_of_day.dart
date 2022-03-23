import 'package:flutter/material.dart';

class ScheduleTimeOfDay {
  ScheduleTimeOfDay.available({required this.time})
      : availability = TimeOfDayAvailability.available;
  ScheduleTimeOfDay.unavailable({required this.time})
      : availability = TimeOfDayAvailability.unavailable;
  final TimeOfDay time;
  final TimeOfDayAvailability availability;
}

enum TimeOfDayAvailability { available, unavailable }
