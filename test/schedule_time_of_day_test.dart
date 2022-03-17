
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  test('ScheduleTimeOfDay initializer .available', () {
    const time = TimeOfDay(hour: 10, minute: 0);
    final schedule = ScheduleTimeOfDay.available(time: time);
    expect(schedule.time, time);
    expect(schedule.availability, TimeOfDayAvailability.available);
  });
  test('ScheduleTimeOfDay initializer .unavailable', () {
    const time = TimeOfDay(hour: 10, minute: 0);
    final schedule = ScheduleTimeOfDay.unavailable(time: time);
    expect(schedule.time, time);
    expect(schedule.availability, TimeOfDayAvailability.unavailable);
  });
}