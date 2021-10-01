import 'package:flutter/material.dart';
import '../models/interval_range.dart';
import '../models/minute_interval.dart';
import '../models/schedule_item_position.dart';
import 'day_schedule_list.dart';
import 'interval_containers/appointment_container_overlay.dart';
import 'time_of_day_widget.dart';
import '../helpers/time_of_day_extensions.dart';

mixin DayScheduleListMethods {
  final LayerLink link = LayerLink();
  late OverlayEntry appointmentOverlayEntry;
  late ScheduleItemPosition appointmentOverlayPosition;

  double calculateTimeOfDayIndicatorsInset(double timeOfDayWidgetHeight) {
    return timeOfDayWidgetHeight / 2.0;
  }

  ScheduleItemPosition calculateItemRangePosition<T extends IntervalRange>(
      {required T itemRange,
      required MinuteInterval minimumMinuteInterval,
      required double minimumMinuteIntervalHeight,
      required double insetVertical,
      required ScheduleTimeOfDay? firstValidTime}) {
    final int deltaTop =
        itemRange.start.toMinutes - (firstValidTime?.time.toMinutes ?? 0);
    final deltaIntervalInMinutes = itemRange.deltaIntervalIMinutes;

    return ScheduleItemPosition(
        top: minimumMinuteIntervalHeight *
                (deltaTop / minimumMinuteInterval.numberValue) +
            insetVertical,
        height: minimumMinuteIntervalHeight *
            (deltaIntervalInMinutes / minimumMinuteInterval.numberValue));
  }

  IntervalRange calculateItervalRangeFor({
    required TimeOfDay start,
    required double newDurationHeight,
    required MinuteInterval minimumMinuteInterval,
    required double minimumMinuteIntervalHeight,
  }) {
    final int durationInMinutes = convertDeltaYToMinutes(
      deltaY: newDurationHeight,
      minimumMinuteInterval: minimumMinuteInterval,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
    );
    final DateTime endDateTime =
        DateTime(DateTime.now().year, 1, 1, start.hour, start.minute)
            .add(Duration(minutes: durationInMinutes));
    final TimeOfDay end = TimeOfDay.fromDateTime(endDateTime);
    return IntervalRange(start: start, end: end);
  }

  IntervalRange calculateItervalRangeForNewTop({
    required IntervalRange range,
    required double newTop,
    required TimeOfDay firstValidTime,
    required double insetVertical,
    required MinuteInterval minimumMinuteInterval,
    required double minimumMinuteIntervalHeight,
  }) {
    final start = range.start;
    final end = range.end;
    final int newStartIncrement =
        firstValidTime.hour > 0 || firstValidTime.minute > 0
            ? firstValidTime.toMinutes
            : 0;
    final int newStartInMinutes = convertDeltaYToMinutes(
          deltaY: newTop - insetVertical,
          minimumMinuteInterval: minimumMinuteInterval,
          minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
        ) +
        newStartIncrement;
    final deltaInMinutes = newStartInMinutes - start.toMinutes;

    final DateTime startDateTime =
        DateTime(DateTime.now().year, 1, 1, start.hour, start.minute)
            .add(Duration(minutes: deltaInMinutes));
    final TimeOfDay newStart = TimeOfDay.fromDateTime(startDateTime);

    final DateTime endDateTime =
        DateTime(DateTime.now().year, 1, 1, end.hour, end.minute)
            .add(Duration(minutes: deltaInMinutes));
    final TimeOfDay newEnd = TimeOfDay.fromDateTime(endDateTime);

    return IntervalRange(start: newStart, end: newEnd);
  }

  int convertDeltaYToMinutes({
    required double deltaY,
    required MinuteInterval minimumMinuteInterval,
    required double minimumMinuteIntervalHeight,
  }) {
    return ((deltaY * minimumMinuteInterval.numberValue) /
            minimumMinuteIntervalHeight)
        .round();
  }

  bool canUpdateHeightOfInterval<S extends IntervalRange>({
    required int index,
    required List<S> appointments,
    required List<IntervalRange> unavailableIntervals,
    required double newHeight,
    required double minimumMinuteIntervalHeight,
    required MinuteInterval minimumMinuteInterval,
    required MinuteInterval appointmentMinimumDuration,
    required List<ScheduleTimeOfDay> validTimesList,
  }) {

    bool canUpdate = true;
    final interval = appointments[index];
    final possibleNewInterval = calculateItervalRangeFor(
      start: interval.start,
      newDurationHeight: newHeight,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
      minimumMinuteInterval: minimumMinuteInterval,
    );
    final hasNextInterval = index < appointments.length - 1;
    if (hasNextInterval) {
      final nextInterval = appointments[index + 1];
      canUpdate &= !nextInterval.intersects(possibleNewInterval);
    }
    final exceedsMaxValidTime =
        possibleNewInterval.end > validTimesList.last.time;
    final intersectsUnavailableInterval = unavailableIntervals
        .any((element) => element.intersects(possibleNewInterval));
    final isBiggerThanMinimumDuration =
        possibleNewInterval.deltaIntervalIMinutes >=
            appointmentMinimumDuration.numberValue;
    canUpdate &= !exceedsMaxValidTime;
    canUpdate &= !intersectsUnavailableInterval;
    canUpdate &= isBiggerThanMinimumDuration;
    return canUpdate;
  }

  bool canUpdateTopOfInterval<S extends IntervalRange>({
    required int index,
    required List<S> appointments,
    required double newTop,
    required double insetVertical,
    required double contentHeight,
    required double minimumMinuteIntervalHeight,
    required MinuteInterval minimumMinuteInterval,
    required List<ScheduleTimeOfDay> validTimesList,
  }) {
    final interval = appointments[index];
    final currentPosition = calculateItemRangePosition<S>(
      itemRange: interval,
      minimumMinuteInterval: minimumMinuteInterval,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
      insetVertical: insetVertical,
      firstValidTime: validTimesList.first,
    );
    final minTop = insetVertical;
    final maxEnd = contentHeight - insetVertical;
    return newTop >= minTop && newTop + currentPosition.height <= maxEnd;
  }

  void showUpdateTopOverlay<S extends IntervalRange>({
    required BuildContext context,
    required S interval,required double insetVertical,
    required MinuteInterval minimumMinuteInterval,
    required double minimumMinuteIntervalHeight,
    required List<ScheduleTimeOfDay> validTimesList,
    required double timeOfDayWidgetHeight,
    required AppointmentWidgetBuilder<S> appointmentBuilder,
  }) {
    appointmentOverlayPosition = calculateItemRangePosition<S>(
      itemRange: interval,
      minimumMinuteInterval: minimumMinuteInterval,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
      insetVertical: insetVertical,
      firstValidTime: validTimesList.first,
    );

    appointmentOverlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        final updatedInterval = calculateItervalRangeForNewTop(
          range: interval,
          newTop: appointmentOverlayPosition.top,
          firstValidTime: validTimesList.first.time,
          insetVertical: insetVertical,
          minimumMinuteInterval: minimumMinuteInterval,
          minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
        );
        return AppointmentContainerOverlay(
          position: appointmentOverlayPosition,
          interval: updatedInterval,
          link: link,
          timeIndicatorsInset: calculateTimeOfDayIndicatorsInset(timeOfDayWidgetHeight),
          child: appointmentBuilder(context, interval),
        );
      },
    );
    Overlay.of(context)?.insert(appointmentOverlayEntry);
  }

  void updateAppointmentOverlay(double newTop) {
    appointmentOverlayPosition = appointmentOverlayPosition.withNewTop(newTop);
    appointmentOverlayEntry.markNeedsBuild();
  }

  void hideAppoinmentOverlay() {
    appointmentOverlayEntry.remove();
  }

}
