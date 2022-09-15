import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/helpers/schedule_item_position_utils.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_container.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';
import 'package:flutter/material.dart';

class AppointmentContainerUtils {
  static List<AppointmentContainer> buildList<S extends IntervalRange>({
    required List<S> appointments,
    required AppointmentUpdateCallbackController callbackController,
    required double insetVertical,
    required num? childWidthLine,
    required ScheduleTimeOfDay firstValidTime,
    required double minimumMinuteIntervalHeight,
    required MinuteInterval minimumMinuteInterval,
    required Widget Function(S appointment, double height) appointmentBuilder,
    required Widget? Function(S appointment, double height) optionalChildLine,
  }) {
    return appointments.map((appointment) {
      final index = appointments.indexOf(appointment);
      final position = ScheduleItemPositionUtils.calculateItemRangePosition(
        itemRange: appointment,
        insetVertical: insetVertical,
        firstValidTime: firstValidTime,
        minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
        minimumMinuteInterval: minimumMinuteInterval,
      );

      return AppointmentContainer(
        appointment: appointment,
        callbackController: callbackController,
        itemIndex: index,
        position: position,
        optionalChildWidthLine: childWidthLine ?? 0,
        optionalChildLine: optionalChildLine(
          appointments[index],
          position.height
        ),
        child: appointmentBuilder(
          appointments[index],
          position.height,
        ),
      );
    }).toList();
  }
}