import 'package:day_schedule_list/src/models/interval_range.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';
import 'package:flutter/material.dart';

import '../../day_schedule_list_widget.dart';
import '../appointment_container/appointment_time_of_day_indicator_widget.dart';

class AppointmentContainerOverlay extends StatefulWidget {
  const AppointmentContainerOverlay({
    required this.updateMode,
    required this.position,
    required this.interval,
    required this.link,
    required this.child,
    required this.timeIndicatorsInset,
    required this.onTapToStopEditing,
    Key? key,
  }) : super(key: key);

  final ScheduleItemPosition position;
  final LayerLink link;
  final Widget child;
  final double timeIndicatorsInset;
  final IntervalRange interval;
  final AppointmentUpdateMode updateMode;

  final void Function() onTapToStopEditing;

  @override
  _AppointmentContainerOverlayState createState() =>
      _AppointmentContainerOverlayState();
}

class _AppointmentContainerOverlayState
    extends State<AppointmentContainerOverlay> {

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 5,
      child: CompositedTransformFollower(
        offset: Offset(0, widget.position.top),
        link: widget.link,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if ([
              AppointmentUpdateMode.position,
              AppointmentUpdateMode.durationFromTop,
            ].contains(widget.updateMode))
              AppointmentTimeOfDayIndicatorWidget.start(
                time: widget.interval.start,
                timeIndicatorsInset: widget.timeIndicatorsInset,
              ),
            if ([
              AppointmentUpdateMode.position,
              AppointmentUpdateMode.durationFromBottom,
            ].contains(widget.updateMode))
              AppointmentTimeOfDayIndicatorWidget.end(
                time: widget.interval.end,
                timeIndicatorsInset: widget.timeIndicatorsInset,
              ),
            Padding(
              padding: const EdgeInsets.only(
                left: DayScheduleListWidget.intervalContainerLeftInset,
              ),
              child: SizedBox(
                width: double.infinity,
                height: widget.position.height,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// abstract class AppointmentOverlayUpdateCallbackController {
//   bool canUpdateTo(ScheduleItemPosition position, int index, AppointmentUpdateMode mode);
//   void onUpdateStart(ScheduleItemPosition position);
//   void onNewUpdate(ScheduleItemPosition position);
//   void onUpdateEnd(ScheduleItemPosition position, int index);
//   void onUpdateCancel();
// }
//
// class AppointmentOverlayUpdateController {
//   AppointmentOverlayUpdateController({
//     required this.inherited,
//     required this.originalPosition,
//     required this.itemIndex,
//     required this.callbackController,
//   }) : _currentPosition = originalPosition;
//
//   final ScheduleItemPosition originalPosition;
//   final int itemIndex;
//   final AppointmentOverlayUpdateCallbackController callbackController;
//   final DayScheduleListInherited inherited;
//
//   late ScheduleItemPosition _currentPosition;
//   double _pendingDeltaYForUpdateStep = 0;
//   Offset _oldOffsetFromOrigin = Offset.zero;
//   bool _didMove = false;
//   LoopDirection _runningUpdateLoopDirection = LoopDirection.none;
//   AppointmentUpdateMode mode = AppointmentUpdateMode.none;
//
//   void onLongPressDown(AppointmentUpdateMode mode){
//     HapticFeedback.heavyImpact();
//     this.mode = mode;
//     _pendingDeltaYForUpdateStep = 0;
//     _oldOffsetFromOrigin = Offset.zero;
//     _didMove = false;
//     callbackController.onUpdateStart(_currentPosition);
//   }
//
//   void onLongPressEnd(LongPressEndDetails _) {
//     _runningUpdateLoopDirection = LoopDirection.none;
//     if (_didMove && callbackController.canUpdateTo(_currentPosition, itemIndex, mode)) {
//       callbackController.onUpdateEnd(_currentPosition, itemIndex);
//       _resetCurrentPosition();
//     } else {
//       callbackController.onUpdateCancel();
//     }
//   }
//
//   void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
//     _didMove = true;
//     final updateStep = inherited.minimumMinuteIntervalHeight;
//     final offsetY = details.offsetFromOrigin.dy - _oldOffsetFromOrigin.dy;
//     final double nextPendingIncrement = _pendingDeltaYForUpdateStep + offsetY;
//     if (nextPendingIncrement.abs() >= updateStep) {
//       final multiplier = (nextPendingIncrement / updateStep).roundToDouble();
//       _tryToPerformRescheduleIncrementBy(
//         updateStep * multiplier,
//       );
//       _pendingDeltaYForUpdateStep = 0;
//     } else {
//       _pendingDeltaYForUpdateStep = nextPendingIncrement;
//     }
//     _oldOffsetFromOrigin = details.offsetFromOrigin;
//   }
//
//
//   void _tryToPerformRescheduleIncrementBy(double value) {
//     final localCurrentTop = _currentPosition.top;
//     final newTop = localCurrentTop + value;
//     final newPosition = _currentPosition.withNewTop(newTop);
//     if (inherited.newSchedulePositionIsOnMaxVisibleTop(
//         newPosition, _currentPosition)) {
//       if (_runningUpdateLoopDirection != LoopDirection.top) {
//         _runningUpdateLoopDirection = LoopDirection.top;
//         _runUpdatePositionLoop(
//           newTop: newTop,
//           newPosition: newPosition,
//           increment: value,
//           direction: LoopDirection.top,
//         );
//       }
//     } else if (inherited.newSchedulePositionIsOnMaxVisibleBottom(
//         newPosition, _currentPosition)) {
//       if (_runningUpdateLoopDirection != LoopDirection.bottom) {
//         _runningUpdateLoopDirection = LoopDirection.bottom;
//         _runUpdatePositionLoop(
//           newTop: newTop,
//           newPosition: newPosition,
//           increment: value,
//           direction: LoopDirection.bottom,
//         );
//       }
//     } else {
//       _runningUpdateLoopDirection = LoopDirection.none;
//       if (callbackController.canUpdateTo(newPosition, itemIndex, mode)) {
//         _updatePositionAndInform(newPosition);
//       }
//     }
//   }
//
//   void _runUpdatePositionLoop({
//     required ScheduleItemPosition newPosition,
//     required double newTop,
//     required double increment,
//     required LoopDirection direction,
//   }) {
//     var loopNewPosition = newPosition;
//     var loopNewTop = newTop;
//     Future.doWhile(() {
//       if (callbackController.canUpdateTo(loopNewPosition, itemIndex, mode)) {
//         _updatePositionAndInform(loopNewPosition);
//         loopNewTop = loopNewTop + increment;
//         loopNewPosition = _currentPosition.withNewTop(loopNewTop);
//         return Future.delayed(
//           const Duration(milliseconds: 100),
//               () => _runningUpdateLoopDirection == direction,
//         );
//       } else {
//         return false;
//       }
//     });
//   }
//
//   void _updatePositionAndInform(ScheduleItemPosition newPosition) {
//     _currentPosition = newPosition;
//     callbackController.onNewUpdate(_currentPosition);
//   }
//
//
//   void _resetCurrentPosition() {
//     _currentPosition = originalPosition;
//   }
// }
