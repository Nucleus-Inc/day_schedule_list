import 'package:flutter/material.dart';
import '../models/interval_range.dart';
import '../models/minute_interval.dart';
import '../models/schedule_item_position.dart';
import 'day_schedule_list_widget.dart';
import 'interval_containers/appointment_container_overlay.dart';
import 'time_of_day_widget.dart';
import '../helpers/time_of_day_extensions.dart';

mixin DayScheduleListWidgetMethods {
  final MinuteInterval minimumMinuteInterval = MinuteInterval.one;
  final MinuteInterval appointmentMinimumDuration = MinuteInterval.thirty;

  double get hourHeight => 0;

  late double minimumMinuteIntervalHeight =
      (hourHeight * minimumMinuteInterval.numberValue.toDouble()) / 60.0;

  late double timeOfDayWidgetHeight = 10 * minimumMinuteIntervalHeight;

  final LayerLink link = LayerLink();
  late OverlayEntry appointmentOverlayEntry;
  late ScheduleItemPosition appointmentOverlayPosition;

  double calculateTimeOfDayIndicatorsInset(double timeOfDayWidgetHeight) {
    return timeOfDayWidgetHeight / 2.0;
  }

  bool intersectsOtherInterval<T extends IntervalRange>({
    required List<T> intervals,
    T? excludingInterval,
    required IntervalRange newInterval,
  }) {
    return intervals.any((element) {
      return excludingInterval != null
          ? element != excludingInterval && newInterval.intersects(element)
          : newInterval.intersects(element);
    });
  }

  bool belongsToInternalUnavailableRange({
    required TimeOfDay time,
    required List<IntervalRange> unavailableIntervals,
  }) {
    final List<IntervalRange> internalUnavailableIntervals =
        unavailableIntervals.length >= 3
            ? unavailableIntervals.sublist(1, unavailableIntervals.length - 1)
            : [];
    return internalUnavailableIntervals
        .any((element) => element.containsTimeOfDay(time));
  }

  ScheduleItemPosition calculateItemRangePosition<T extends IntervalRange>({
    required T itemRange,
    required double insetVertical,
    required ScheduleTimeOfDay? firstValidTime,
  }) {
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
  }) {
    final int durationInMinutes = convertDeltaYToMinutes(
      deltaY: newDurationHeight,
    );
    final DateTime endDateTime =
        DateTime(DateTime.now().year, 1, 1, start.hour, start.minute)
            .add(Duration(minutes: durationInMinutes));
    TimeOfDay end;
    if (endDateTime.day != 1) {
      end = const TimeOfDay(hour: 23, minute: 59);
    } else {
      end = TimeOfDay.fromDateTime(endDateTime);
    }
    return IntervalRange(start: start, end: end);
  }

  IntervalRange calculateItervalRangeForNewTop({
    required IntervalRange range,
    required double newTop,
    required TimeOfDay firstValidTime,
    required double insetVertical,
  }) {
    final start = range.start;
    final end = range.end;
    final int newStartIncrement =
        firstValidTime.hour > 0 || firstValidTime.minute > 0
            ? firstValidTime.toMinutes
            : 0;
    final int newStartInMinutes = convertDeltaYToMinutes(
          deltaY: newTop - insetVertical,
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
  }) {
    return ((deltaY * minimumMinuteInterval.numberValue) /
            minimumMinuteIntervalHeight)
        .round();
  }

  List<ScheduleTimeOfDay> populateValidTimesList({
    required List<IntervalRange> unavailableIntervals,
  }) {
    List<ScheduleTimeOfDay> validTimesList = [];
    final verifyUnavailableIntervals = unavailableIntervals.isNotEmpty;
    for (var item = 0; item < 25; item++) {
      final hasTimeBefore = item > 0;
      final TimeOfDay time =
          TimeOfDay(hour: item == 24 ? 23 : item, minute: item == 24 ? 59 : 0);
      if (verifyUnavailableIntervals) {
        final IntervalRange first = unavailableIntervals.first;
        final IntervalRange last = unavailableIntervals.last;

        final belongsToFirst = first.containsTimeOfDay(time);
        final belongsToLast = last.containsTimeOfDay(time);

        if (hasTimeBefore) {
          final beforeDateTime =
              DateTime(DateTime.now().year, 1, 1, time.hour, time.minute)
                  .subtract(const Duration(hours: 1));
          final timeBefore = TimeOfDay.fromDateTime(beforeDateTime);
          final timeBeforeBelongsToFirst = first.containsTimeOfDay(timeBefore);
          final timeBeforeBelongsToLast = last.containsTimeOfDay(timeBefore);
          if (timeBeforeBelongsToFirst && !belongsToFirst) {
            final dateTimeToAdd = DateTime(
                    DateTime.now().year, 1, 1, first.end.hour, first.end.minute)
                .add(Duration(minutes: minimumMinuteInterval.numberValue));
            final timeOfDayToAdd = TimeOfDay.fromDateTime(dateTimeToAdd);
            if (time.toMinutes - timeOfDayToAdd.toMinutes >=
                minimumMinuteInterval.numberValue) {
              validTimesList.add(
                belongsToInternalUnavailableRange(
                  time: timeOfDayToAdd,
                  unavailableIntervals: unavailableIntervals,
                )
                    ? ScheduleTimeOfDay.unavailable(time: timeOfDayToAdd)
                    : ScheduleTimeOfDay.available(time: timeOfDayToAdd),
              );
            }
          } else if (!timeBeforeBelongsToLast && belongsToLast) {
            final dateTimeToAdd = DateTime(DateTime.now().year, 1, 1,
                    last.start.hour, last.start.minute)
                .subtract(Duration(minutes: minimumMinuteInterval.numberValue));
            final timeOfDayToAdd = TimeOfDay.fromDateTime(dateTimeToAdd);
            if (time.toMinutes - timeOfDayToAdd.toMinutes >=
                minimumMinuteInterval.numberValue) {
              validTimesList.add(
                belongsToInternalUnavailableRange(
                  time: timeOfDayToAdd,
                  unavailableIntervals: unavailableIntervals,
                )
                    ? ScheduleTimeOfDay.unavailable(time: timeOfDayToAdd)
                    : ScheduleTimeOfDay.available(time: timeOfDayToAdd),
              );
            }
          }
        }

        if (!belongsToFirst && !belongsToLast) {
          validTimesList.add(
            belongsToInternalUnavailableRange(
              time: time,
              unavailableIntervals: unavailableIntervals,
            )
                ? ScheduleTimeOfDay.unavailable(time: time)
                : ScheduleTimeOfDay.available(time: time),
          );
        }
      } else {
        validTimesList.add(
          belongsToInternalUnavailableRange(
            time: time,
            unavailableIntervals: unavailableIntervals,
          )
              ? ScheduleTimeOfDay.unavailable(time: time)
              : ScheduleTimeOfDay.available(time: time),
        );
      }
    }
    return validTimesList;
  }

  bool canUpdateHeightOfInterval<S extends IntervalRange>({
    required int index,
    required List<S> appointments,
    required List<IntervalRange> unavailableIntervals,
    required double newHeight,
    required List<ScheduleTimeOfDay> validTimesList,
  }) {
    bool canUpdate = true;
    final interval = appointments[index];
    final possibleNewInterval = calculateItervalRangeFor(
      start: interval.start,
      newDurationHeight: newHeight,
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
    required List<ScheduleTimeOfDay> validTimesList,
  }) {
    final interval = appointments[index];
    final currentPosition = calculateItemRangePosition<S>(
      itemRange: interval,
      insetVertical: insetVertical,
      firstValidTime: validTimesList.first,
    );
    final minTop = insetVertical;
    final maxEnd = contentHeight - insetVertical;
    return newTop >= minTop && newTop + currentPosition.height <= maxEnd;
  }

  void showUpdateTopOverlay<S extends IntervalRange>({
    required BuildContext context,
    required S interval,
    required double insetVertical,
    required List<ScheduleTimeOfDay> validTimesList,
    required double timeOfDayWidgetHeight,
    required AppointmentWidgetBuilder<S> appointmentBuilder,
  }) {
    appointmentOverlayPosition = calculateItemRangePosition<S>(
      itemRange: interval,
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
        );
        return AppointmentContainerOverlay(
          position: appointmentOverlayPosition,
          interval: updatedInterval,
          link: link,
          timeIndicatorsInset:
              calculateTimeOfDayIndicatorsInset(timeOfDayWidgetHeight),
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
