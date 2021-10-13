import 'package:flutter/material.dart';

extension HelperMethods on TimeOfDay {
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
}
