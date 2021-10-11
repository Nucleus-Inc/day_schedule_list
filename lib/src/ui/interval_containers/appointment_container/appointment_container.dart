import 'package:flutter/material.dart';

import '../../day_schedule_list_widget.dart';
import '../../dynamic_height_container.dart';
import '../../../models/schedule_item_position.dart';
import '../dynamic_position_container.dart';
import 'appointment_time_of_day_indicator_widget.dart';

class AppointmentContainer extends StatefulWidget {
  const AppointmentContainer({
    required this.position,
    required this.timeIndicatorsInset,
    required this.updateHeightStep,
    required this.canUpdateHeightTo,
    required this.onUpdateHeightEnd,
    required this.canUpdateTopTo,
    required this.onUpdateTopEnd,
    required this.onNewUpdateTop,
    required this.onUpdateTopStart,
    required this.onUpdateTopCancel,
    required this.endTimeOfDayForPossibleNewHeight,
    required this.child,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    this.dragIndicatorBorderColor,
    Key? key,
  }) : super(key: key);

  final ScheduleItemPosition position;
  final Widget child;
  final double updateHeightStep;
  final double timeIndicatorsInset;

  final CanUpdateToHeight canUpdateHeightTo;
  final UpdateHeightCallback onUpdateHeightEnd;
  final TimeOfDay Function(double newHeight) endTimeOfDayForPossibleNewHeight;

  final CanUpdateToTopPosition canUpdateTopTo;
  final UpdateTopPositionCallback onUpdateTopEnd;
  final UpdateTopPositionCallback onNewUpdateTop;
  final void Function() onUpdateTopStart;
  final void Function() onUpdateTopCancel;

  final Color? dragIndicatorColor;
  final Color? dragIndicatorBorderColor;
  final double? dragIndicatorBorderWidth;

  @override
  _AppointmentContainerState createState() => _AppointmentContainerState();
}

class _AppointmentContainerState extends State<AppointmentContainer> {
  late ValueNotifier<AppointmentUpdatingMode> _updateMode;
  late ValueNotifier<TimeOfDay> _possibleNewEndDate;

  @override
  void initState() {
    _updateMode = ValueNotifier(AppointmentUpdatingMode.none);
    _possibleNewEndDate = ValueNotifier(
        widget.endTimeOfDayForPossibleNewHeight(widget.position.height));
    super.initState();
  }

  @override
  void dispose() {
    _updateMode.dispose();
    _possibleNewEndDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position.top,
      right: 0,
      left: 0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ValueListenableBuilder(
            valueListenable: _updateMode,
            builder: (context, value, child) {
              return Visibility(
                visible: value == AppointmentUpdatingMode.changeHeight,
                child: child!,
              );
            },
            child: ValueListenableBuilder<TimeOfDay>(
              valueListenable: _possibleNewEndDate,
              builder: (context, endDate, child) {
                return AppointmentTimeOfDayIndicatorWidget.end(
                  time: endDate,
                  timeIndicatorsInset: widget.timeIndicatorsInset,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: DayScheduleListWidget.intervalContainerLeftInset,
            ),
            child: DynamicTopPositionContainer(
              top: widget.position.top,
              canUpdateTopTo: widget.canUpdateTopTo,
              onNewUpdate: _onNewTopUpdate,
              onUpdateEnd: _onTopUpdateEnd,
              onUpdateCancel: _onUpdateTopCancel,
              onUpdateStart: _onUpdateTopStart,
              child: DynamicHeightContainer(
                currentHeight: widget.position.height,
                updateStep: widget.updateHeightStep,
                canUpdateHeightTo: widget.canUpdateHeightTo,
                dragIndicatorBorderColor: widget.dragIndicatorBorderColor,
                dragIndicatorBorderWidth: widget.dragIndicatorBorderWidth,
                dragIndicatorColor: widget.dragIndicatorColor,
                onUpdateEnd: _onUpdateHeightEnd,
                onUpdateStart: _onUpdateHeightStart,
                onUpdateCancel: _onUpdateHeightCancel,
                onNewUpdate: _onNewUpdateHeight,
                child: ValueListenableBuilder<AppointmentUpdatingMode>(
                  valueListenable: _updateMode,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity:
                          value == AppointmentUpdatingMode.changeTop ? 0.5 : 1,
                      child: child!,
                    );
                  },
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
    // return ValueListenableBuilder<ScheduleItemPosition>(
    //   valueListenable: _currentPosition,
    //   builder: (
    //     BuildContext context,
    //     ScheduleItemPosition position,
    //     Widget? child,
    //   ) {
    //     return Positioned(
    //       top: position.top,
    //       right: 0,
    //       left: 0,
    //       child: child!,
    //     );
    //   },
    //   child: Stack(
    //     clipBehavior: Clip.none,
    //     children: [
    //       AppointmentTimeOfDayIndicatorWidget.start(
    //         timeIndicatorsInset: widget.timeIndicatorsInset,
    //         updateMode: _updateMode,
    //       ),
    //       AppointmentTimeOfDayIndicatorWidget.end(
    //         timeIndicatorsInset: widget.timeIndicatorsInset,
    //         updateMode: _updateMode,
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(
    //           left: DayScheduleList.intervalContainerLeftInset,
    //         ),
    //         child: DynamicTopPositionContainer(
    //           top: widget.position.top,
    //           canUpdateTopTo: widget.canUpdateTopTo,
    //           onNewUpdate: _onNewTopUpdate,
    //           onUpdateEnd: _onTopUpdateEnd,
    //           onUpdateStart: _onUpdateTopStart,
    //           onUpdateCancel: _onUpdateTopCancel,
    //           child: DynamicHeightContainer(
    //             currentHeight: widget.position.height,
    //             updateStep: widget.updateHeightStep,
    //             canUpdateHeightTo: widget.canUpdateHeightTo,
    //             onUpdateEnd: _onUpdateHeightEnd,
    //             onUpdateStart: _onUpdateHeightStart,
    //             onUpdateCancel: _onUpdateHeightCancel,
    //             child: ValueListenableBuilder<AppointmentUpdatingMode>(
    //               valueListenable: _updateMode,
    //               builder: (context, value, child) {
    //                 return FractionallySizedBox(
    //                   widthFactor:
    //                       value == AppointmentUpdatingMode.changeTop ? 1.02 : 1,
    //                   child: widget.child,
    //                 );
    //               },
    //             ),
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }

  void _onUpdateTopStart() {
    _updateModeToChangingTop();
    widget.onUpdateTopStart();
  }

  void _onNewTopUpdate(double newTop) {
    widget.onNewUpdateTop(newTop);
    //_currentPosition.value = _currentPosition.value.withNewTop(newTop);
  }

  void _onTopUpdateEnd(double newTop) {
    _updateModeTofinishChangeTop();
    widget.onUpdateTopEnd(newTop);
  }

  void _onUpdateTopCancel() {
    _updateModeTofinishChangeTop();
    widget.onUpdateTopCancel();
  }

  void _onUpdateHeightStart() {
    _possibleNewEndDate.value =
        widget.endTimeOfDayForPossibleNewHeight(widget.position.height);
    _updateModeToChangingHeight();
  }

  void _onUpdateHeightEnd(double newHeight) async {
    _updateModeTofinishChangeHeight();
    widget.onUpdateHeightEnd(newHeight);
  }

  void _onNewUpdateHeight(double newHeight) {
    _possibleNewEndDate.value =
        widget.endTimeOfDayForPossibleNewHeight(newHeight);
  }

  void _onUpdateHeightCancel() {
    _updateModeTofinishChangeHeight();
  }

  void _updateModeToChangingTop() {
    if (_updateMode.value == AppointmentUpdatingMode.none) {
      _updateMode.value = AppointmentUpdatingMode.changeTop;
    }
  }

  void _updateModeToChangingHeight() {
    if (_updateMode.value == AppointmentUpdatingMode.none) {
      _updateMode.value = AppointmentUpdatingMode.changeHeight;
    }
  }

  void _updateModeTofinishChangeTop() {
    if (_updateMode.value == AppointmentUpdatingMode.changeTop) {
      _updateMode.value = AppointmentUpdatingMode.none;
    }
  }

  void _updateModeTofinishChangeHeight() {
    if (_updateMode.value == AppointmentUpdatingMode.changeHeight) {
      _updateMode.value = AppointmentUpdatingMode.none;
    }
  }
}

enum AppointmentUpdatingMode { changeTop, changeHeight, none }
