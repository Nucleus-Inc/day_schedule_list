import 'package:day_schedule_list/src/helpers/generic_utils.dart';
import 'package:day_schedule_list/src/helpers/interval_range_utils.dart';
import 'package:day_schedule_list/src/helpers/schedule_item_position_utils.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/models/unavailable_interval_to_add_appointment_exception.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container_overlay/appointment_overlay_controller.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';
import 'package:flutter/material.dart';
import '../models/interval_range.dart';
import '../models/minute_interval.dart';
import '../models/schedule_item_position.dart';
import '../helpers/time_of_day_extensions.dart';
import '../helpers/date_time_extensions.dart';

mixin DayScheduleListWidgetMixin {
  static const double defaultHourHeight = 100;
  static const MinuteInterval defaultMinimumMinuteInterval = MinuteInterval.one;
  static const MinuteInterval defaultAppointmentMinimumDuration =
      MinuteInterval.fifteen;

  double get hourHeight => 0;
  MinuteInterval get minimumMinuteInterval => defaultMinimumMinuteInterval;
  MinuteInterval get appointmentMinimumDuration =>
      defaultAppointmentMinimumDuration;
  double get timeOfDayWidgetHeight {
    return minimumMinuteIntervalHeight < 2
        ? 10 * minimumMinuteIntervalHeight
        : 17;
  }

  late double minimumMinuteIntervalHeight =
      (hourHeight * minimumMinuteInterval.numberValue) / 60.0;

  late ScrollController scrollController;
  late AppointmentOverlayController overlayController;

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

  List<IntervalRange> buildInternalUnavailableIntervals({
    required List<IntervalRange> unavailableIntervals,
  }) {
    try {
      return unavailableIntervals
          .where(
            (element) =>
                element.start > const TimeOfDay(hour: 0, minute: 0) &&
                element.end < const TimeOfDay(hour: 23, minute: 59),
          )
          .toList();
    } catch (error) {
      return [];
    }
  }

  bool belongsToInternalUnavailableRange({
    required TimeOfDay time,
    required List<IntervalRange> unavailableIntervals,
  }) {
    final List<IntervalRange> internalUnavailableIntervals =
        buildInternalUnavailableIntervals(
      unavailableIntervals: unavailableIntervals,
    );
    return internalUnavailableIntervals
        .any((element) => element.containsTimeOfDay(time));
  }

  ScheduleItemPosition calculateItemRangePosition<T extends IntervalRange>({
    required T itemRange,
    required double insetVertical,
    required ScheduleTimeOfDay? firstValidTime,
  }) {
    return ScheduleItemPositionUtils.calculateItemRangePosition(
      itemRange: itemRange,
      insetVertical: insetVertical,
      firstValidTime: firstValidTime,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
      minimumMinuteInterval: minimumMinuteInterval,
    );
  }

  int calculateCloserMinutesThatIsMultipleOfMinimumMinuteInterval(
      {required int minutes}) {
    return GenericUtils
        .calculateCloserMinutesThatIsMultipleOfMinimumMinuteInterval(
      minutes: minutes,
      minimumMinuteInterval: minimumMinuteInterval,
    );
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
        validTimesList.addAll(
          _validScheduleTimeOfDayListWhenNeedToVerifyForUnavailableIntervals(
            time: time,
            hasTimeBefore: hasTimeBefore,
            unavailableIntervals: unavailableIntervals,
          ),
        );
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

  List<ScheduleTimeOfDay>
      _validScheduleTimeOfDayListWhenNeedToVerifyForUnavailableIntervals({
    required TimeOfDay time,
    required bool hasTimeBefore,
    required List<IntervalRange> unavailableIntervals,
  }) {
    List<ScheduleTimeOfDay> validTimesList = [];

    final IntervalRange firstUnavailableInterval = unavailableIntervals.first;
    final IntervalRange lastUnavailableInterval = unavailableIntervals.last;

    final belongsToFirst =
        firstUnavailableInterval.containsTimeOfDayPartialClosed(
      time: time,
      closedRangeOnStart: true,
      closedRangeOnEnd: false,
    );
    final belongsToLast =
        lastUnavailableInterval.containsTimeOfDayPartialClosed(
      time: time,
      closedRangeOnStart: false,
      closedRangeOnEnd: true,
    );

    if (hasTimeBefore) {
      final validTime = _buildScheduleTimeOfDayWhenHaveTimeBeforeIfNeeded(
        time: time,
        belongsToLast: belongsToLast,
        belongsToFirst: belongsToFirst,
        unavailableIntervals: unavailableIntervals,
        firstUnavailableInterval: firstUnavailableInterval,
        lastUnavailableInterval: lastUnavailableInterval,
      );

      if (validTime != null) {
        validTimesList.add(validTime);
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

    return validTimesList;
  }

  ScheduleTimeOfDay? _buildScheduleTimeOfDayWhenHaveTimeBeforeIfNeeded(
      {required TimeOfDay time,
      required bool belongsToFirst,
      required bool belongsToLast,
      required IntervalRange firstUnavailableInterval,
      required IntervalRange lastUnavailableInterval,
      required List<IntervalRange> unavailableIntervals}) {
    final timeBefore = time.subtract(hours: 1, minutes: 0);
    final timeBeforeBelongsToFirst =
        firstUnavailableInterval.containsTimeOfDayPartialClosed(
      time: timeBefore,
      closedRangeOnStart: true,
      closedRangeOnEnd: false,
    );
    final timeBeforeBelongsToLast =
        lastUnavailableInterval.containsTimeOfDayPartialClosed(
      time: timeBefore,
      closedRangeOnStart: false,
      closedRangeOnEnd: true,
    );

    return _validScheduleTimeOfDayWhenHaveTimeBefore(
      time: time,
      belongsToFirst: belongsToFirst,
      belongsToLast: belongsToLast,
      timeBeforeBelongsToFirst: timeBeforeBelongsToFirst,
      timeBeforeBelongsToLast: timeBeforeBelongsToLast,
      firstUnavailableInterval: firstUnavailableInterval,
      lastUnavailableInterval: lastUnavailableInterval,
      unavailableIntervals: unavailableIntervals,
    );
  }

  ScheduleTimeOfDay? _validScheduleTimeOfDayWhenHaveTimeBefore(
      {required TimeOfDay time,
      required bool timeBeforeBelongsToFirst,
      required bool belongsToFirst,
      required bool timeBeforeBelongsToLast,
      required bool belongsToLast,
      required IntervalRange firstUnavailableInterval,
      required IntervalRange lastUnavailableInterval,
      required List<IntervalRange> unavailableIntervals}) {
    if (timeBeforeBelongsToFirst && !belongsToFirst) {
      final timeOfDayToAdd = firstUnavailableInterval.end;
      if (time.toMinutes - timeOfDayToAdd.toMinutes >=
          minimumMinuteInterval.numberValue) {
        return belongsToInternalUnavailableRange(
          time: timeOfDayToAdd,
          unavailableIntervals: unavailableIntervals,
        )
            ? ScheduleTimeOfDay.unavailable(time: timeOfDayToAdd)
            : ScheduleTimeOfDay.available(time: timeOfDayToAdd);
      }
    } else if (!timeBeforeBelongsToLast && belongsToLast) {
      final timeOfDayToAdd = lastUnavailableInterval.start;
      if (time.toMinutes - timeOfDayToAdd.toMinutes >=
          minimumMinuteInterval.numberValue) {
        return belongsToInternalUnavailableRange(
          time: timeOfDayToAdd,
          unavailableIntervals: unavailableIntervals,
        )
            ? ScheduleTimeOfDay.unavailable(time: timeOfDayToAdd)
            : ScheduleTimeOfDay.available(time: timeOfDayToAdd);
      }
    }
    return null;
  }

  bool canUpdateHeightOfInterval<S extends IntervalRange>({
    required AppointmentUpdateMode mode,
    required int index,
    required List<S> appointments,
    required List<IntervalRange> unavailableIntervals,
    required double newHeight,
    required List<ScheduleTimeOfDay> validTimesList,
  }) {
    bool canUpdate = true;
    final interval = appointments[index];
    if (![
      AppointmentUpdateMode.durationFromBottom,
      AppointmentUpdateMode.durationFromTop
    ].contains(mode)) {
      return false;
    }
    final possibleNewInterval = mode == AppointmentUpdateMode.durationFromBottom
        ? IntervalRangeUtils.calculateItervalRangeForNewHeight(
            start: interval.start,
            newDurationHeight: newHeight,
            minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
            minimumMinuteInterval: minimumMinuteInterval,
          )
        : IntervalRangeUtils.calculateItervalRangeForNewHeightFromTop(
            newDurationHeight: newHeight,
            end: interval.end,
            minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
            minimumMinuteInterval: minimumMinuteInterval,
          );

    switch (mode) {
      case AppointmentUpdateMode.durationFromTop:
        final hasBeforeInterval = index > 0;
        if (hasBeforeInterval) {
          final beforeInterval = appointments[index - 1];
          canUpdate &= !beforeInterval.intersects(possibleNewInterval);
        }
        final exceedsMinValidTime =
            possibleNewInterval.start < validTimesList.first.time;
        canUpdate &= !exceedsMinValidTime;
        break;
      case AppointmentUpdateMode.durationFromBottom:
        final hasNextInterval = index < appointments.length - 1;
        if (hasNextInterval) {
          final nextInterval = appointments[index + 1];
          canUpdate &= !nextInterval.intersects(possibleNewInterval);
        }
        final exceedsMaxValidTime =
            possibleNewInterval.end > validTimesList.last.time;
        canUpdate &= !exceedsMaxValidTime;
        break;
      default:
        return false;
    }

    final intersectsUnavailableInterval = unavailableIntervals
        .any((element) => element.intersects(possibleNewInterval));

    final isBiggerThanMinimumDuration =
        possibleNewInterval.deltaIntervalIMinutes >=
            appointmentMinimumDuration.numberValue;
    canUpdate &= isBiggerThanMinimumDuration;
    canUpdate &= !intersectsUnavailableInterval;

    return canUpdate;
  }

  bool canUpdatePositionOfInterval<S extends IntervalRange>({
    required ScheduleItemPosition newPosition,
    required double insetVertical,
    required double contentHeight,
  }) {
    final minTop = insetVertical;
    final maxEnd = contentHeight - insetVertical;
    final canUpdate = newPosition.top >= minTop &&
        newPosition.top + newPosition.height <= maxEnd;
    return canUpdate;
  }

  ///Try to create a new appointment at the position tapped by the user
  IntervalRange? newAppointmentForTappedPosition({
    required Offset startPosition,
    required List<IntervalRange> appointments,
    required List<IntervalRange> unavailableIntervals,
    required ScheduleTimeOfDay firstValidTimeList,
    required ScheduleTimeOfDay lastValidTimeList,
  }) {
    final possibleStart =
        _calculatePossibleStartOfNewAppointmentForTappedPosition(
      startPosition: startPosition,
      firstValidTimeList: firstValidTimeList,
    );

    final possibleEnd = _calculatePossibleEndOfNewAppointment(
      possibleStart: possibleStart,
      lastValidTimeList: lastValidTimeList,
    );

    IntervalRange? possibleNewAppointment =
        IntervalRange(start: possibleStart, end: possibleEnd);

    final List<IntervalRange> fullList = [
      ...appointments,
      ...buildInternalUnavailableIntervals(
        unavailableIntervals: unavailableIntervals,
      ),
    ];

    List<IntervalRange> intersections = [];
    try {
      intersections = fullList
          .where(
            (element) => element.intersects(possibleNewAppointment!),
          )
          .toList();
    } catch (error) {
      debugPrint('$error');
    }

    ///Adjusts duration avoiding intersections
    possibleNewAppointment =
        _adjustPossibleNewAppointmentDurationAvoidingIntersections(
      intersections: intersections,
      possibleNewAppointment: possibleNewAppointment,
    );

    ///Adjusts duration avoiding min valid time interval and max valid time interval
    if (possibleNewAppointment != null &&
        possibleNewAppointment.start < firstValidTimeList.time) {
      possibleNewAppointment.start = firstValidTimeList.time;
    } else if (possibleNewAppointment != null &&
        possibleNewAppointment.end > lastValidTimeList.time) {
      possibleNewAppointment.end = lastValidTimeList.time;
    }

    if (possibleNewAppointment == null ||
        possibleNewAppointment.deltaIntervalIMinutes <
            appointmentMinimumDuration.numberValue) {
      throw UnavailableIntervalToAddAppointmentException(
        appointmentMinimumDuration: appointmentMinimumDuration,
      );
    }

    return possibleNewAppointment;
  }

  TimeOfDay _calculatePossibleStartOfNewAppointmentForTappedPosition({
    required Offset startPosition,
    required ScheduleTimeOfDay firstValidTimeList,
  }) {
    const offsetInMinutesToCenterAppointmentOnTouchArea = 30;

    final now = DateTime.now();
    final baseStartInMinutes = GenericUtils.convertDeltaYToMinutes(
      deltaY: startPosition.dy,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
      minimumMinuteInterval: minimumMinuteInterval,
    );

    final startInMinutes =
        calculateCloserMinutesThatIsMultipleOfMinimumMinuteInterval(
      minutes:
          baseStartInMinutes - offsetInMinutesToCenterAppointmentOnTouchArea,
    );

    final baseStartDate = DateTime(now.year, now.month, now.day,
        firstValidTimeList.time.hour, firstValidTimeList.time.minute, 0);
    final startDate = baseStartDate.add(
      Duration(minutes: startInMinutes),
    );
    return baseStartDate.isSameDay(dateTime: startDate)
        ? TimeOfDay.fromDateTime(
            startDate,
          )
        : firstValidTimeList.time;
  }

  TimeOfDay _calculatePossibleEndOfNewAppointment({
    required TimeOfDay possibleStart,
    required ScheduleTimeOfDay lastValidTimeList,
  }) {
    final now = DateTime.now();
    final baseEndDate = DateTime(now.year, now.month, now.day,
        possibleStart.hour, possibleStart.minute, 0);
    final endDate = baseEndDate.add(const Duration(hours: 1));
    return endDate.isSameDay(dateTime: baseEndDate)
        ? TimeOfDay.fromDateTime(
            endDate,
          )
        : lastValidTimeList.time;
  }

  IntervalRange? _adjustPossibleNewAppointmentDurationAvoidingIntersections({
    required List<IntervalRange> intersections,
    required IntervalRange? possibleNewAppointment,
  }) {
    IntervalRange? appointment = possibleNewAppointment;
    for (var index = 0; index < intersections.length; index++) {
      if (appointment != null) {
        final intersectedInterval = intersections[index];
        final containsStart =
            intersectedInterval.containsTimeOfDay(appointment.start);
        final containsEnd =
            intersectedInterval.containsTimeOfDay(appointment.end);
        final needChangeStart = containsStart && !containsEnd;
        final needChangeEnd = !containsStart && containsEnd;
        final intersectionIsContainedOnAppointment =
            appointment.containsTimeOfDay(
                  intersectedInterval.start,
                ) &&
                appointment.containsTimeOfDay(
                  intersectedInterval.end,
                );

        if (needChangeStart) {
          debugPrint('1');
          appointment.start = intersectedInterval.end;
        } else if (needChangeEnd) {
          debugPrint('2');
          appointment.end = intersectedInterval.start;
        } else if (containsStart && containsEnd) {
          appointment = null;
          break;
        } else if (intersectionIsContainedOnAppointment &&
            intersectedInterval.start.toMinutes - appointment.start.toMinutes >=
                minimumMinuteInterval.numberValue) {
          appointment.end = intersectedInterval.start;
        } else if (intersectionIsContainedOnAppointment &&
            appointment.end.toMinutes - intersectedInterval.end.toMinutes >=
                minimumMinuteInterval.numberValue) {
          appointment.start = intersectedInterval.end;
        }
      }
    }
    return appointment;
  }

  void updateScrollViewOffsetBy({
    required ScheduleItemPosition newPosition,
    required ScheduleItemPosition oldPosition,
    required AppointmentUpdateMode updateMode,
  }) {
    double offsetIncrement = ScheduleItemPositionUtils.calculateOffsetIncrement(
      oldPosition: oldPosition,
      newPosition: newPosition,
      updateMode: updateMode,
    );

    final currentOffset = scrollController.offset;
    var resultOffset = currentOffset + offsetIncrement;
    if (resultOffset < 0) {
      scrollController.jumpTo(0);
    } else {
      scrollController.jumpTo(resultOffset);
    }
  }
}
