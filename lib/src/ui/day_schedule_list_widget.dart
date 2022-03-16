import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/models/unavailable_interval_to_add_appointment_exception.dart';
import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_inherited.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_stack.dart';
import 'package:flutter/material.dart';

import 'day_schedule_list_widget_mixin.dart';
import 'interval_containers/appointment_container/appointment_container.dart';
import 'interval_containers/unavailable_interval_container.dart';
import 'time_of_day_widget.dart';
import '../helpers/time_of_day_extensions.dart';

///Signature of function to build your widget that represents an appointment.
///Never forget to consider the parameter height, it is the available space you
///have to alocate it.
typedef AppointmentWidgetBuilder<K extends IntervalRange> = Widget Function(
  BuildContext context,
  K appointment,
  double height,
);

///Signature of function to update some updated appointment.
typedef UpdateAppointDuration<K extends IntervalRange> = Future<bool> Function(
  K appointment,
  IntervalRange newInterval,
);

///Signature of function to update some updated appointment.
typedef NewAppointmentAt = void Function(
  IntervalRange? interval,
  DayScheduleListWidgetErrors? error,
);

///This is the widget that represents your daily schedule.
///Here you will see all your appointments for the [referenceDate].
class DayScheduleListWidget<T extends IntervalRange> extends StatefulWidget {
  static const double intervalContainerLeftInset = 40;
  const DayScheduleListWidget({
    required this.referenceDate,
    required this.unavailableIntervals,
    required this.appointments,
    required this.updateAppointDuration,
    required this.appointmentBuilder,
    this.createNewAppointmentAt,
    this.hourHeight = DayScheduleListWidgetMixin.defaultHourHeight,
    this.minimumMinuteInterval =
        DayScheduleListWidgetMixin.defaultMinimumMinuteInterval,
    this.appointmentMinimumDuration =
        DayScheduleListWidgetMixin.defaultAppointmentMinimumDuration,
    this.scrollController,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    this.dragIndicatorBorderColor,
    this.customDragIndicator,
    Key? key,
  })  : assert(
          minimumMinuteInterval <= appointmentMinimumDuration,
          'minimumMinuteInterval must be <= appointmentMinimumDuration',
        ),
        assert(hourHeight > 0, 'hourHeight must be != null and > 0'),
        super(key: key);

  ///DateTime that it represents.
  final DateTime referenceDate;

  ///List of unavailable intervals. For Example, you only allow to add new
  ///appointments from 8am to 6pm this list would be:
  ///
  /// IntervalRange(
  ///   start: const TimeOfDay(hour: 0, minute: 0),
  ///   end: const TimeOfDay(hour: 8, minute: 0),
  /// ),
  /// IntervalRange(
  ///   start: const TimeOfDay(hour: 18, minute: 0),
  ///   end: const TimeOfDay(hour: 23, minute: 59),
  /// )
  final List<IntervalRange> unavailableIntervals;

  ///List of appointments [T] on [referenceDate]
  final List<T> appointments;

  ///A callback that is called everytime you need to update your server
  ///or local database with updated informations of appointment.
  final UpdateAppointDuration<T> updateAppointDuration;

  ///A Builder called for every appointment of [appointments] to build your
  /// widget that represents it.
  final AppointmentWidgetBuilder<T> appointmentBuilder;

  ///A Builder called for every appointment of [appointments] to build your
  /// widget that represents it.
  /// When this value is null any kind of edition is disabled
  final NewAppointmentAt? createNewAppointmentAt;

  ///The convertion parameter from one hour to height dimension.
  ///Choose a value that best fits your needs.
  ///
  /// Default value = [DayScheduleListWidgetMixin.defaultHourHeight]
  final double hourHeight;

  ///The minimum time interval that will be incremented or decremented to an appointment
  ///
  /// Default value = [DayScheduleListWidgetMixin.defaultMinimumMinuteInterval]
  final MinuteInterval minimumMinuteInterval;

  ///The minimum duration in minutes that an appointment will have.
  ///
  /// Default value = [DayScheduleListWidgetMixin.defaultAppointmentMinimumDuration]
  final MinuteInterval appointmentMinimumDuration;

  /// An object that can be used to control the position to which the scroll
  /// view is scrolled.
  final ScrollController? scrollController;

  ///The color to be applied to the default drag indicator widget.
  final Color? dragIndicatorColor;

  ///The color to be applied to the default drag indicator widget border.
  final Color? dragIndicatorBorderColor;

  ///The width to be applied to the default drag indicator widget border.
  final double? dragIndicatorBorderWidth;

  ///Custom drag indicator widget builder. Use it to customize the widget that
  ///appears on top left and bottom right of appointment widget when it enters on
  ///edit mode.
  ///
  ///
  ///
  ///When this value is not null [dragIndicatorColor], [dragIndicatorBorderColor]
  ///and [dragIndicatorBorderWidth] values are not used.
  final CustomDragIndicatorBuilder? customDragIndicator;

  @override
  _DayScheduleListWidgetState<T> createState() =>
      _DayScheduleListWidgetState<T>();
}

class _DayScheduleListWidgetState<S extends IntervalRange>
    extends State<DayScheduleListWidget<S>> with DayScheduleListWidgetMixin {
  @override
  double get hourHeight => widget.hourHeight;
  @override
  MinuteInterval get minimumMinuteInterval => widget.minimumMinuteInterval;
  @override
  MinuteInterval get appointmentMinimumDuration =>
      widget.appointmentMinimumDuration;

  bool get allowEdition => widget.createNewAppointmentAt != null;

  List<ScheduleTimeOfDay> validTimesList = [];
  final GlobalKey _validTimesListColumnKey = GlobalKey();

  @override
  void initState() {
    validTimesList = populateValidTimesList(
      unavailableIntervals: widget.unavailableIntervals,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DayScheduleListWidget<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.appointments.sort((a, b) => a.start <= b.start ? -1 : 1);
    //if(oldWidget.unavailableIntervals != widget.unavailableIntervals) {
    validTimesList = populateValidTimesList(
      unavailableIntervals: widget.unavailableIntervals,
    );
    //}
  }

  @override
  Widget build(BuildContext context) {
    const baseInsetVertical = 20.0;
    final insetVertical = baseInsetVertical +
        calculateTimeOfDayIndicatorsInset(timeOfDayWidgetHeight);
    List<S> appointments = widget.appointments;
    List<IntervalRange> unavailableIntervals = widget.unavailableIntervals;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      child: DayScheduleListInherited(
        allowEdition: allowEdition,
        minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
        timeOfDayWidgetHeight: timeOfDayWidgetHeight,
        minimumMinuteInterval: minimumMinuteInterval,
        validTimesList: validTimesList,
        dragIndicatorBorderColor: widget.dragIndicatorBorderColor,
        dragIndicatorBorderWidth: widget.dragIndicatorBorderWidth,
        dragIndicatorColor: widget.dragIndicatorColor,
        customDragIndicator: widget.customDragIndicator,
        child: Builder(
          builder: (context) {
            return DayScheduleListStack(
              validTimesListColumnKey: _validTimesListColumnKey,
              link: link,
              onTapUpOnDayScheduleList: widget.createNewAppointmentAt != null
                  ? _onTapUpOnDayScheduleList
                  : null,
              internalUnavailableIntervals: buildInternalUnavailableIntervals(
                unavailableIntervals: widget.unavailableIntervals,
              ).map((IntervalRange interval) {
                return UnavailableIntervalContainer(
                  interval: interval,
                  position: calculateItemRangePosition(
                    itemRange: interval,
                    insetVertical: insetVertical,
                    firstValidTime: validTimesList.first,
                  ),
                );
              }).toList(),
              appointments: [
                ...appointments.map((appointment) {
                  final index = appointments.indexOf(appointment);
                  final position = calculateItemRangePosition(
                    itemRange: appointment,
                    insetVertical: insetVertical,
                    firstValidTime: validTimesList.first,
                  );
                  return AppointmentContainer(
                    updateStep: minimumMinuteIntervalHeight,
                    timeIndicatorsInset: timeOfDayWidgetHeight / 2.0,
                    position: position,
                    canUpdateHeightTo: (newHeight, from) =>
                        canUpdateHeightOfInterval<S>(
                      from: from,
                      index: index,
                      appointments: appointments,
                      newHeight: newHeight,
                      unavailableIntervals: unavailableIntervals,
                      validTimesList: validTimesList,
                    ),
                    canUpdatePositionTo: (ScheduleItemPosition newPosition) =>
                        canUpdatePositionOfInterval(
                      newPosition: newPosition,
                      insetVertical: insetVertical,
                      contentHeight: _validTimesListColumnKey
                              .currentContext?.size?.height ??
                          0,
                    ),
                    onUpdatePositionEnd: (ScheduleItemPosition newPosition) =>
                        _onUpdatePositionEnd(
                      newPosition: newPosition,
                      index: index,
                      insetVertical: insetVertical,
                      appointments: appointments,
                    ),
                    onUpdatePositionStart: (mode) => showUpdateOverlay<S>(
                      context: context,
                      interval: appointments[index],
                      mode: mode,
                      insetVertical: insetVertical,
                      timeOfDayWidgetHeight: timeOfDayWidgetHeight,
                      validTimesList: validTimesList,
                      appointmentBuilder: widget.appointmentBuilder,
                    ),
                    onNewUpdatePosition: (newPosition) =>
                        updateAppointmentOverlay(newPosition),
                    onUpdatePositionCancel: () => hideAppoinmentOverlay(),
                    child: widget.appointmentBuilder(
                      context,
                      appointments[index],
                      position.height,
                    ),
                  );
                }).toList(),
              ],
              // appointments: _buildAppointmentsWidgetList(
              //   insetVertical: insetVertical,
              // ),
            );
          },
        ),
      ),
    );
  }

  void _onTapUpOnDayScheduleList(TapUpDetails details) {
    try {
      final appointment = newAppointmentForTappedPosition(
        startPosition: details.localPosition,
        firstValidTimeList: validTimesList.first,
        lastValidTimeList: validTimesList.last,
        appointments: widget.appointments,
        unavailableIntervals: widget.unavailableIntervals,
      );
      _createNewAppointmentAt(appointment, null);
    } on UnavailableIntervalToAddAppointmentException {
      _createNewAppointmentAt(
        null,
        DayScheduleListWidgetErrors.unavailableIntervalToAddAppointment,
      );
    }
  }

  void _createNewAppointmentAt(
      IntervalRange? appointment, DayScheduleListWidgetErrors? error) {
    final action = widget.createNewAppointmentAt;
    if (action != null) {
      action(appointment, error);
    }
  }

  void _onUpdatePositionEnd({
    required ScheduleItemPosition newPosition,
    required int index,
    required List<S> appointments,
    required double insetVertical,
  }) {
    hideAppoinmentOverlay();
    _updateAppointIntervalForNewPosition(
      index: index,
      appointments: appointments,
      newPosition: newPosition,
      insetVertical: insetVertical,
    );
  }

  Future<bool> _updateAppointIntervalForNewPosition({
    required int index,
    required List<S> appointments,
    required ScheduleItemPosition newPosition,
    required double insetVertical,
  }) async {
    final appointment = appointments[index];
    final newInterval = calculateItervalRangeForNewPosition(
      range: appointment,
      newPosition: newPosition,
      firstValidTime: validTimesList.first,
      insetVertical: insetVertical,
    );

    final intersectsOtherAppt = intersectsOtherInterval<S>(
      newInterval: newInterval,
      excludingInterval: appointment,
      intervals: appointments,
    );

    final intersectsSomeUnavailableRange = intersectsOtherInterval(
      newInterval: newInterval,
      intervals: widget.unavailableIntervals,
    );

    if (intersectsOtherAppt || intersectsSomeUnavailableRange) {
      return false;
    }

    final success =
        await widget.updateAppointDuration(appointment, newInterval);

    return success;
  }
}
