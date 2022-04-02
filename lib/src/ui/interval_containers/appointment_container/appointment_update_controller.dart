import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppointmentUpdateController {
  AppointmentUpdateController({
    required this.updateStep,
    required this.originalPosition,
    required this.itemIndex,
    required this.callbackController,
  }) : _currentPosition = originalPosition;

  final double updateStep;
  final ScheduleItemPosition originalPosition;
  final int itemIndex;
  final AppointmentUpdateCallbackController callbackController;

  late ScheduleItemPosition _currentPosition;
  double _pendingDeltaYForUpdateStep = 0;
  Offset _oldOffsetFromOrigin = Offset.zero;
  bool _didMove = false;
  LoopDirection _runningUpdateLoopDirection = LoopDirection.none;
  AppointmentUpdateMode mode = AppointmentUpdateMode.none;

  void onLongPressDown<S extends IntervalRange>(
    AppointmentUpdateMode mode,
    S appointment,
  ) {
    HapticFeedback.heavyImpact();
    this.mode = mode;
    _pendingDeltaYForUpdateStep = 0;
    _oldOffsetFromOrigin = Offset.zero;
    _didMove = false;
    callbackController.onUpdateStart(_currentPosition, appointment, mode);
  }

  void onLongPressEnd(LongPressEndDetails _) {
    _runningUpdateLoopDirection = LoopDirection.none;
    if (_didMove &&
        callbackController.canUpdateTo(_currentPosition, itemIndex, mode)) {
      callbackController.onUpdateEnd(_currentPosition, itemIndex);
      _resetCurrentPosition();
    } else {
      callbackController.onUpdateCancel();
    }
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _didMove = true;
    final offsetY = details.offsetFromOrigin.dy - _oldOffsetFromOrigin.dy;
    final double nextPendingIncrement = _pendingDeltaYForUpdateStep + offsetY;
    if (nextPendingIncrement.abs() >= updateStep) {
      final multiplier = (nextPendingIncrement / updateStep).roundToDouble();
      _tryToPerformRescheduleIncrementBy(
        updateStep * multiplier,
      );
      _pendingDeltaYForUpdateStep = 0;
    } else {
      _pendingDeltaYForUpdateStep = nextPendingIncrement;
    }
    _oldOffsetFromOrigin = details.offsetFromOrigin;
  }

  void _tryToPerformRescheduleIncrementBy(double value) {
    double newTop = _currentPosition.top;
    double newHeight = _currentPosition.height;
    ScheduleItemPosition newPosition = _currentPosition;

    double topIncrement = 0;
    double heightIncrement = 0;

    if (mode == AppointmentUpdateMode.position) {
      newTop += value;
      newPosition = _currentPosition.withNewTop(newTop);
      topIncrement = value;
    } else {
      final localCurrentHeight = _currentPosition.height;
      topIncrement = mode == AppointmentUpdateMode.durationFromTop ? value : 0;
      heightIncrement =
          value * (mode == AppointmentUpdateMode.durationFromBottom ? 1 : -1);
      newHeight = localCurrentHeight + heightIncrement;
      newTop += topIncrement;
      newPosition = ScheduleItemPosition(top: newTop, height: newHeight);
    }

    if (callbackController.newSchedulePositionIsOnMaxVisibleTop(
        newPosition, _currentPosition, mode)) {
      if (_runningUpdateLoopDirection != LoopDirection.top) {
        _runningUpdateLoopDirection = LoopDirection.top;
        _runUpdatePositionLoop(
          newTop: newTop,
          newHeight: newHeight,
          newPosition: newPosition,
          topIncrement: topIncrement,
          heightIncrement: heightIncrement,
          direction: LoopDirection.top,
        );
      }
    } else if (callbackController.newSchedulePositionIsOnMaxVisibleBottom(
        newPosition, _currentPosition, mode)) {
      if (_runningUpdateLoopDirection != LoopDirection.bottom) {
        _runningUpdateLoopDirection = LoopDirection.bottom;
        _runUpdatePositionLoop(
          newTop: newTop,
          newHeight: newHeight,
          newPosition: newPosition,
          topIncrement: topIncrement,
          heightIncrement: heightIncrement,
          direction: LoopDirection.bottom,
        );
      }
    } else {
      _runningUpdateLoopDirection = LoopDirection.none;
      if (callbackController.canUpdateTo(newPosition, itemIndex, mode)) {
        _updatePositionAndInform(newPosition);
      }
    }
  }

  void _runUpdatePositionLoop({
    required ScheduleItemPosition newPosition,
    required double newTop,
    required double newHeight,
    required double topIncrement,
    required double heightIncrement,
    required LoopDirection direction,
  }) {
    var loopNewPosition = newPosition;
    var loopNewTop = newTop;
    var loopNewHeight = newHeight;
    Future.doWhile(() {
      if (callbackController.canUpdateTo(loopNewPosition, itemIndex, mode)) {
        _updatePositionAndInform(loopNewPosition);
        loopNewTop += topIncrement;
        loopNewHeight += heightIncrement;
        loopNewPosition = ScheduleItemPosition(
          top: loopNewTop,
          height: loopNewHeight,
        );
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => _runningUpdateLoopDirection == direction,
        );
      } else {
        return false;
      }
    });
  }

  void _updatePositionAndInform(ScheduleItemPosition newPosition) {
    _currentPosition = newPosition;
    callbackController.onNewUpdate(_currentPosition, mode);
  }

  void _resetCurrentPosition() {
    _currentPosition = originalPosition;
  }
}

abstract class AppointmentUpdateCallbackController<S extends IntervalRange> {
  bool newSchedulePositionIsOnMaxVisibleTop(
    ScheduleItemPosition newPosition,
    ScheduleItemPosition oldPosition,
    AppointmentUpdateMode updateMode,
  );
  bool newSchedulePositionIsOnMaxVisibleBottom(
    ScheduleItemPosition newPosition,
    ScheduleItemPosition oldPosition,
    AppointmentUpdateMode updateMode,
  );
  bool canUpdateTo(
    ScheduleItemPosition position,
    int index,
    AppointmentUpdateMode mode,
  );
  void onUpdateStart(
    ScheduleItemPosition position,
    S appointment,
    AppointmentUpdateMode mode,
  );
  void onNewUpdate(
    ScheduleItemPosition position,
    AppointmentUpdateMode mode,
  );
  void onUpdateEnd(
    ScheduleItemPosition position,
    int index,
  );
  void onUpdateCancel();
}

enum AppointmentUpdateMode {
  position,
  durationFromTop,
  durationFromBottom,
  none
}

enum LoopDirection { top, bottom, none }
