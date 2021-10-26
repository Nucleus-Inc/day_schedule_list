import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/models/exceptions.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/valid_time_of_day_list_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/interval_range.dart';
import 'day_schedule_list_widget_extensions.dart';
import 'interval_containers/appointment_container/appointment_container.dart';
import 'interval_containers/unavailable_interval_container.dart';
import 'time_of_day_widget.dart';
import '../helpers/time_of_day_extensions.dart';

///Signature of function to build your widget that represents an appointment.
///Never forget to consider the parameter height, it is the available space you
///have to alocate it.
typedef AppointmentWidgetBuilder<K extends IntervalRange> = Widget Function(
    BuildContext context, K appointment, double height);

///Signature of function to update some updated appointment.
typedef UpdateAppointDuration<K extends IntervalRange> = Future<bool> Function(
    K appointment, IntervalRange newInterval);

///Signature of function to update some updated appointment.
typedef NewAppointmentAt = void Function(
    IntervalRange? interval, DayScheduleListWidgetErrors? error);

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
    required this.createNewAppointmentAt,
    this.hourHeight = 100.0,
    this.scrollController,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    this.dragIndicatorBorderColor,
    Key? key,
  })  : assert(hourHeight > 0, 'hourHeight must be != null and > 0'),
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
  final NewAppointmentAt createNewAppointmentAt;

  ///The convertion parameter from one hour to height dimension.
  ///Choose a value that best fits your needs.
  ///
  /// Default value = 100.0
  final double hourHeight;

  /// An object that can be used to control the position to which the scroll
  /// view is scrolled.
  final ScrollController? scrollController;

  ///The color to be applied to the default drag indicator widget.
  final Color? dragIndicatorColor;

  ///The color to be applied to the default drag indicator widget border.
  final Color? dragIndicatorBorderColor;

  ///The width to be applied to the default drag indicator widget border.
  final double? dragIndicatorBorderWidth;

  @override
  _DayScheduleListWidgetState<T> createState() =>
      _DayScheduleListWidgetState<T>();
}

class _DayScheduleListWidgetState<S extends IntervalRange>
    extends State<DayScheduleListWidget<S>> with DayScheduleListWidgetMethods {
  @override
  double get hourHeight => widget.hourHeight;

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
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            CompositedTransformTarget(
              link: link,
              child: ValidTimeOfDayListWidget(
                key: _validTimesListColumnKey,
                validTimesList: validTimesList,
                timeOfDayWidgetHeight: timeOfDayWidgetHeight,
                minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
                minimumMinuteInterval: minimumMinuteInterval,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (TapUpDetails details) {
                  try {
                    final appointment = newAppointmentForTappedPosition(
                      startPosition: details.localPosition,
                      firstValidTimeList: validTimesList.first,
                      lastValidTimeList: validTimesList.last,
                      appointments: widget.appointments,
                      unavailableIntervals: widget.unavailableIntervals,
                    );
                    widget.createNewAppointmentAt(appointment, null);
                  } on UnavailableIntervalToAddAppointmentException {
                    widget.createNewAppointmentAt(
                      null,
                      DayScheduleListWidgetErrors
                          .unavailableIntervalToAddAppointment,
                    );
                  }
                },
                child: Container(),
              ),
            ),
            const Positioned(
              top: 0,
              left: 35,
              bottom: 0,
              child: VerticalDivider(),
            ),
            ..._buildUnavailableIntervalsWidgetList(
              insetVertical: insetVertical,
            ),
            ..._buildAppointmentsWidgetList(
              insetVertical: insetVertical,
              timeOfDayWidgetHeight: timeOfDayWidgetHeight,
            ),
          ],
        ),
      ),
    );
  }

  List<UnavailableIntervalContainer> _buildUnavailableIntervalsWidgetList(
      {required double insetVertical}) {
    final List<IntervalRange> unavailableSublist = buildInternalUnavailableIntervals(unavailableIntervals: widget.unavailableIntervals,);
    return unavailableSublist.map((IntervalRange interval) {
      return UnavailableIntervalContainer(
        interval: interval,
        position: calculateItemRangePosition(
          itemRange: interval,
          insetVertical: insetVertical,
          firstValidTime: validTimesList.first,
        ),
      );
    }).toList();
  }

  List<AppointmentContainer> _buildAppointmentsWidgetList({
    required double insetVertical,
    required double timeOfDayWidgetHeight,
  }) {
    List<AppointmentContainer> items = [];
    List<S> appointments = widget.appointments;
    List<IntervalRange> unavailableIntervals = widget.unavailableIntervals;
    for (var index = 0; index < appointments.length; index++) {
      final interval = appointments[index];
      items.add(_buildAppointment(
        index: index,
        appointments: appointments,
        unavailableIntervals: unavailableIntervals,
        interval: interval,
        insetVertical: insetVertical,
      ));
    }
    return items;
  }

  AppointmentContainer _buildAppointment({
    required int index,
    required List<S> appointments,
    required List<IntervalRange> unavailableIntervals,
    required S interval,
    required double insetVertical,
  }) {
    final position = calculateItemRangePosition(
      itemRange: interval,
      insetVertical: insetVertical,
      firstValidTime: validTimesList.first,
    );
    return AppointmentContainer(
      updateStep: minimumMinuteIntervalHeight,
      timeIndicatorsInset: timeOfDayWidgetHeight / 2.0,
      dragIndicatorColor: widget.dragIndicatorColor,
      dragIndicatorBorderWidth: widget.dragIndicatorBorderWidth,
      dragIndicatorBorderColor: widget.dragIndicatorBorderColor,
      position: position,
      canUpdateHeightTo: (newHeight, from) => canUpdateHeightOfInterval<S>(
        insetVertical: insetVertical,
        from: from,
        index: index,
        appointments: appointments,
        newHeight: newHeight,
        unavailableIntervals: unavailableIntervals,
        validTimesList: validTimesList,
      ),
      canUpdatePositionTo: (ScheduleItemPosition newPosition) =>
          canUpdatePositionOfInterval(
        index: index,
        newPosition: newPosition,
        insetVertical: insetVertical,
        appointments: appointments,
        contentHeight:
            _validTimesListColumnKey.currentContext?.size?.height ?? 0,
      ),
      onUpdatePositionEnd: (ScheduleItemPosition newPosition) {
        hideAppoinmentOverlay();
        _updateAppointIntervalForNewPosition(
          index: index,
          appointments: appointments,
          newPosition: newPosition,
          insetVertical: insetVertical,
        );
      },
      onUpdatePositionStart: (mode) => showUpdateOverlay<S>(
        context: context,
        interval: interval,
        mode: mode,
        insetVertical: insetVertical,
        timeOfDayWidgetHeight: timeOfDayWidgetHeight,
        validTimesList: validTimesList,
        appointmentBuilder: widget.appointmentBuilder,
      ),
      onNewUpdatePosition: (newPosition) =>
          updateAppointmentOverlay(newPosition),
      onUpdatePositionCancel: () => hideAppoinmentOverlay(),
      child: widget.appointmentBuilder(context, interval, position.height),
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

    final intersectsSomeUnavailRange = intersectsOtherInterval(
      newInterval: newInterval,
      intervals: widget.unavailableIntervals,
    );

    if (intersectsOtherAppt || intersectsSomeUnavailRange) {
      setState(() {});
      return false;
    }

    final success =
        await widget.updateAppointDuration(appointment, newInterval);

    return success;
  }
}
