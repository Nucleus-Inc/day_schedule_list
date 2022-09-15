import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/helpers/appointment_container_utils.dart';
import 'package:day_schedule_list/src/helpers/generic_utils.dart';
import 'package:day_schedule_list/src/helpers/interval_range_utils.dart';
import 'package:day_schedule_list/src/helpers/schedule_item_position_utils.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/models/unavailable_interval_to_add_appointment_exception.dart';
import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container_overlay/appointment_overlay_controller.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_inherited.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_stack.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';
import 'package:flutter/material.dart';

import 'day_schedule_list_widget_mixin.dart';
import 'interval_containers/unavailable_interval_container.dart';
import '../helpers/time_of_day_extensions.dart';

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
    this.optionalChildWidthLine,
    this.optionalChildLine,
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

  //Add a new widget next to the main widget
  final AppointmentWidgetBuilder<T>? optionalChildLine;

  // Add a width to the secondary widget
  final num? optionalChildWidthLine;

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
    extends State<DayScheduleListWidget<S>>
    with DayScheduleListWidgetMixin, AppointmentUpdateCallbackController<S> {
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
  final GlobalKey _scrollViewKey = GlobalKey();

  double insetVertical() {
    const baseInsetVertical = 20.0;
    return baseInsetVertical +
        GenericUtils.calculateTimeOfDayIndicatorsInset(
          timeOfDayWidgetHeight,
        );
  }

  @override
  void initState() {
    scrollController = widget.scrollController ?? ScrollController();
    overlayController = AppointmentOverlayController(
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
      minimumMinuteInterval: minimumMinuteInterval,
    );
    validTimesList = populateValidTimesList(
      unavailableIntervals: widget.unavailableIntervals,
    );
    super.initState();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    overlayController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DayScheduleListWidget<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.appointments.sort((a, b) => a.start <= b.start ? -1 : 1);
    validTimesList = populateValidTimesList(
      unavailableIntervals: widget.unavailableIntervals,
    );
  }

  @override
  Widget build(BuildContext context) {
    final insetVertical = this.insetVertical();
    List<S> appointments = widget.appointments;

    return DayScheduleListInherited(
      allowEdition: allowEdition,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
      timeOfDayWidgetHeight: timeOfDayWidgetHeight,
      minimumMinuteInterval: minimumMinuteInterval,
      validTimesList: validTimesList,
      dragIndicatorBorderColor: widget.dragIndicatorBorderColor,
      dragIndicatorBorderWidth: widget.dragIndicatorBorderWidth,
      dragIndicatorColor: widget.dragIndicatorColor,
      customDragIndicator: widget.customDragIndicator,
      child: SingleChildScrollView(
        key: _scrollViewKey,
        controller: scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        child: Builder(
          builder: (context) {
            return DayScheduleListStack(
              validTimesListColumnKey: _validTimesListColumnKey,
              link: overlayController.link,
              onTapUpOnDayScheduleList: widget.createNewAppointmentAt != null
                  ? _onTapUpOnDayScheduleList
                  : null,
              internalUnavailableIntervals:
                  UnavailableIntervalContainer.buildList(
                unavailableIntervals: buildInternalUnavailableIntervals(
                  unavailableIntervals: widget.unavailableIntervals,
                ),
                calculatePosition: (interval) => calculateItemRangePosition(
                  itemRange: interval,
                  insetVertical: insetVertical,
                  firstValidTime: validTimesList.first,
                ),
              ),
              appointments: AppointmentContainerUtils.buildList<S>(
                callbackController: this,
                appointments: appointments,
                appointmentBuilder: (appointment, height) =>
                    widget.appointmentBuilder(
                  context,
                  appointment,
                  height,
                ),
                firstValidTime: validTimesList.first,
                insetVertical: insetVertical,
                minimumMinuteInterval: minimumMinuteInterval,
                minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
                childWidthLine: widget.optionalChildWidthLine,
                optionalChildLine: (appointment, height) => widget.optionalChildLine != null
                  ? widget.optionalChildLine!(context, appointment, height)
                  : Container(),
              ),
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

  Future<bool> _updateAppointIntervalForNewPosition({
    required int index,
    required List<S> appointments,
    required ScheduleItemPosition newPosition,
    required double insetVertical,
  }) async {
    final appointment = appointments[index];
    final newInterval = IntervalRangeUtils.calculateItervalRangeForNewPosition(
      range: appointment,
      newPosition: newPosition,
      firstValidTime: validTimesList.first,
      insetVertical: insetVertical,
      minimumMinuteInterval: minimumMinuteInterval,
      minimumMinuteIntervalHeight: minimumMinuteIntervalHeight,
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

  @override
  bool canUpdateTo(ScheduleItemPosition position, int itemIndex,
      AppointmentUpdateMode mode) {
    if (mode == AppointmentUpdateMode.position) {
      return canUpdatePositionOfInterval(
        newPosition: position,
        insetVertical: insetVertical(),
        contentHeight:
            _validTimesListColumnKey.currentContext?.size?.height ?? 0,
      );
    } else {
      return canUpdateHeightOfInterval<S>(
        mode: mode,
        index: itemIndex,
        appointments: widget.appointments,
        newHeight: position.height,
        unavailableIntervals: widget.unavailableIntervals,
        validTimesList: validTimesList,
      );
    }
  }

  @override
  bool newSchedulePositionIsOnMaxVisibleBottom(
    ScheduleItemPosition newPosition,
    ScheduleItemPosition oldPosition,
    AppointmentUpdateMode updateMode,
  ) {
    final windowSize = MediaQuery.of(context).size;
    int sizeCalculation = 0;
    final double offsetIncrement =
        ScheduleItemPositionUtils.calculateOffsetIncrement(
      oldPosition: oldPosition,
      newPosition: newPosition,
      updateMode: updateMode,
    );
    final currentScrollOffset = scrollController.offset;
    if (windowSize.height < 600) {
      sizeCalculation = 350;
    } else if (windowSize.height >= 600 && windowSize.height < 800) {
      sizeCalculation = 380;
    } else if (windowSize.height >= 800) {
      sizeCalculation = 465;
    }
    return windowSize.height -
                (newPosition.top + newPosition.height - currentScrollOffset) <=
            sizeCalculation &&
        offsetIncrement >= 0;
  }

  @override
  bool newSchedulePositionIsOnMaxVisibleTop(
    ScheduleItemPosition newPosition,
    ScheduleItemPosition oldPosition,
    AppointmentUpdateMode updateMode,
  ) {
    final double offsetIncrement =
        ScheduleItemPositionUtils.calculateOffsetIncrement(
      oldPosition: oldPosition,
      newPosition: newPosition,
      updateMode: updateMode,
    );
    final currentScrollOffset = scrollController.offset;
    return newPosition.top - currentScrollOffset <= 60 && offsetIncrement < 0;
  }

  @override
  void onNewUpdate(
    ScheduleItemPosition newPosition,
    AppointmentUpdateMode mode,
  ) {
    final oldPosition = overlayController.appointmentOverlayPosition;
    overlayController.updateAppointmentOverlay(newPosition);

    final isOnMaxVisibleTop = newSchedulePositionIsOnMaxVisibleTop(
      newPosition,
      oldPosition,
      mode,
    );
    final isOnMaxVisibleBottom = newSchedulePositionIsOnMaxVisibleBottom(
      newPosition,
      oldPosition,
      mode,
    );
    if ((isOnMaxVisibleTop || isOnMaxVisibleBottom)) {
      updateScrollViewOffsetBy(
        newPosition: newPosition,
        oldPosition: oldPosition,
        updateMode: mode,
      );
    } else {
      overlayController.updateAppointmentOverlay(newPosition);
    }
  }

  @override
  void onUpdateCancel() {
    overlayController.hideAppoinmentOverlay();
  }

  @override
  void onUpdateEnd(ScheduleItemPosition position, int itemIndex) {
    overlayController.hideAppoinmentOverlay();
    _updateAppointIntervalForNewPosition(
      index: itemIndex,
      appointments: widget.appointments,
      newPosition: position,
      insetVertical: insetVertical(),
    );
  }

  @override
  void onUpdateStart(ScheduleItemPosition position, S appointment,
      AppointmentUpdateMode mode) {
    overlayController.showUpdateOverlay<S>(
      mode: mode,
      context: context,
      position: position,
      interval: appointment,
      validTimesList: validTimesList,
      appointmentBuilder: widget.appointmentBuilder,
      insetVertical: insetVertical(),
      timeOfDayWidgetHeight: timeOfDayWidgetHeight,
    );
  }
}

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

@visibleForTesting
typedef DayScheduleListWidgetGlobalKey = GlobalKey<_DayScheduleListWidgetState>;
