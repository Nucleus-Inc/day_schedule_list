import 'package:flutter/material.dart';

extension TimeOfDayExtensions on TimeOfDay {
  int get toMinutes => hour * 60 + minute;
  bool operator <(Object other) {
    return other is TimeOfDay &&
        (other.hour > hour || (other.hour == hour && other.minute > minute));
  }

  bool operator >(Object other) {
    return other is TimeOfDay &&
        (other.hour < hour || (other.hour == hour && other.minute < minute));
  }

  bool operator <=(Object other) {
    return other is TimeOfDay &&
            (other.hour > hour ||
                (other.hour == hour && other.minute > minute)) ||
        other == this;
  }

  bool operator >=(Object other) {
    return other is TimeOfDay &&
            (other.hour < hour ||
                (other.hour == hour && other.minute < minute)) ||
        other == this;
  }

  TimeOfDay add({required int hours,required int minutes}){
    final now = DateTime.now();
    final newDate = DateTime(now.year,now.month, now.day, hour, minute).add(Duration(
      hours: hours,
      minutes: minutes,
    ));

    return TimeOfDay.fromDateTime(newDate);
  }

  TimeOfDay subtract({required int hours,required int minutes}){
    final now = DateTime.now();
    final newDate = DateTime(now.year,now.month, now.day, hour, minute).subtract(Duration(
      hours: hours,
      minutes: minutes,
    ));
    return TimeOfDay.fromDateTime(newDate);
  }
}
