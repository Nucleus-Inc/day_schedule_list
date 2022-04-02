import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/helpers/generic_utils.dart';
import 'package:day_schedule_list/src/helpers/interval_range_utils.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container_overlay/appointment_container_overlay.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';
import 'package:flutter/material.dart';

class AppointmentOverlayController {
  AppointmentOverlayController({
    required this.minimumMinuteIntervalHeight,
    required this.minimumMinuteInterval,
  });

  final MinuteInterval minimumMinuteInterval;
  final double minimumMinuteIntervalHeight;
  final LayerLink link = LayerLink();

  OverlayEntry? appointmentOverlayEntry;

  late ScheduleItemPosition appointmentOverlayPosition;

  void dispose() {
    appointmentOverlayEntry?.dispose();
  }

  void showUpdateOverlay<S extends IntervalRange>({
    required BuildContext context,
    required AppointmentUpdateMode mode,
    required ScheduleItemPosition position,
    required S interval,
    required List<ScheduleTimeOfDay> validTimesList,
    required AppointmentWidgetBuilder<S> appointmentBuilder,
    required double insetVertical,
    required double timeOfDayWidgetHeight,
  }) {
    appointmentOverlayPosition = ScheduleItemPosition.fromPosition(position);
    hideAppoinmentOverlay();
    appointmentOverlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        final updatedInterval =
            IntervalRangeUtils.calculateItervalRangeForNewPosition(
          range: interval,
          newPosition: appointmentOverlayPosition,
          firstValidTime: validTimesList.first,
          insetVertical: insetVertical,
          minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
          minimumMinuteInterval: minimumMinuteInterval,
        );

        return AppointmentContainerOverlay(
          updateMode: mode,
          position: appointmentOverlayPosition,
          interval: updatedInterval,
          link: link,
          timeIndicatorsInset: GenericUtils.calculateTimeOfDayIndicatorsInset(
            timeOfDayWidgetHeight,
          ),
          onTapToStopEditing: () => hideAppoinmentOverlay(),
          child: appointmentBuilder(
            context,
            interval,
            appointmentOverlayPosition.height,
          ),
        );
      },
    );

    Overlay.of(context)?.insert(appointmentOverlayEntry!);

  }


  void updateAppointmentOverlay(ScheduleItemPosition newPosition) {
    appointmentOverlayPosition = newPosition;
    appointmentOverlayEntry?.markNeedsBuild();
  }

  void hideAppoinmentOverlay() {
    try {
      final overlay = appointmentOverlayEntry;
      if (overlay != null) {
        appointmentOverlayEntry = null;
        overlay.remove();
      }
    } catch (error) {
      debugPrint('$error');
    }
  }
}
