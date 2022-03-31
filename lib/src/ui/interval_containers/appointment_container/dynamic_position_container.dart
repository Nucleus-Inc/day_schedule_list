import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_inherited.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef UpdatePositionCallback = void Function(ScheduleItemPosition position);
typedef CanUpdateToPosition = bool Function(ScheduleItemPosition);
typedef CanUpdateToTop = bool Function(double);
typedef UpdateTopCallback = void Function(double top);

class DynamicPositionContainer extends StatefulWidget {
  const DynamicPositionContainer({
    required this.position,
    required this.child,
    required this.canUpdatePositionTo,
    required this.onUpdatePositionEnd,
    required this.onNewPositionUpdate,
    required this.onUpdatePositionCancel,
    required this.onUpdatePositionStart,
    this.updateStep,
    this.onUpdateEditingModeTap,
    Key? key,
  }) : super(key: key);

  final ScheduleItemPosition position;

  final Widget child;

  ///How much [child] y axis should change by each update during vertical drag gesture.
  final double? updateStep;

  final CanUpdateToPosition canUpdatePositionTo;

  ///Callback called when position update action starts
  final void Function() onUpdatePositionStart;

  ///Callback called when position update action ends
  final UpdatePositionCallback onUpdatePositionEnd;

  ///Callback called when position update action ends
  final void Function() onUpdatePositionCancel;

  ///Callback called when position update action changes
  final UpdatePositionCallback onNewPositionUpdate;

  ///Callback called when tap gesture is detected
  final void Function(bool)? onUpdateEditingModeTap;

  @override
  _DynamicPositionContainerState createState() =>
      _DynamicPositionContainerState();
}

class _DynamicPositionContainerState extends State<DynamicPositionContainer> {
  late ScheduleItemPosition _currentPosition;

  ///The sum of last vertical drag gesture [DragUpdateDetails.delta.dy]  that does not
  ///caused View top to change because it is less than [widget.updateStep]
  double _pendingDeltaYForUpdateStep = 0;
  Offset _oldOffsetFromOrigin = Offset.zero;
  bool _didMove = false;
  late ValueNotifier<bool> editingMode;

  LoopDirection _runningUpdatePositionLoopDirection = LoopDirection.none;

  @override
  void initState() {
    editingMode = ValueNotifier(false);
    _currentPosition = widget.position;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicPositionContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: editingMode,
      builder: (context, editing, child) {
        return GestureDetector(
          onTap: _onDynamicPositionContainerTap,
          onLongPress: editing ? onRescheduleLongPressDown : null,
          //onLongPressStart: onRescheduleLongPressStart,
          onLongPressEnd: editing ? onRescheduleLongPressEnd : null,
          onLongPressMoveUpdate:
              editing ? onRescheduleLongPressMoveUpdate : null,
          child: widget.child,
        );
      },
    );
  }

  void _onDynamicPositionContainerTap() {
    if (widget.onUpdateEditingModeTap != null) {
      HapticFeedback.selectionClick();
      editingMode.value = !editingMode.value;
      widget.onUpdateEditingModeTap!(editingMode.value);
    }
  }

  void onRescheduleLongPressDown() {
    HapticFeedback.heavyImpact();
    _pendingDeltaYForUpdateStep = 0;
    _oldOffsetFromOrigin = Offset.zero;
    _didMove = false;
    widget.onUpdatePositionStart();
  }

  void onRescheduleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _didMove = true;
    double? updateStep = widget.updateStep;
    final offsetY = details.offsetFromOrigin.dy - _oldOffsetFromOrigin.dy;
    if (updateStep != null) {
      final double nextPendingIncrement = _pendingDeltaYForUpdateStep + offsetY;
      if (nextPendingIncrement.abs() >= updateStep) {
        final multiplier = (nextPendingIncrement / updateStep).roundToDouble();
        _tryToPerformRescheduleIncrementBy(
          updateStep * multiplier,
        );
        _pendingDeltaYForUpdateStep = 0;
      } else {
        final inherited = DayScheduleListInherited.of(context);
        final newTop = _currentPosition.top + offsetY;
        final newPosition = _currentPosition.withNewTop(newTop);
        if (inherited.newSchedulePositionIsOnMaxVisibleTop(
            newPosition, _currentPosition)) {
        }
        _pendingDeltaYForUpdateStep = nextPendingIncrement;
      }
    } else {
      _tryToPerformRescheduleIncrementBy(offsetY);
    }
    _oldOffsetFromOrigin = details.offsetFromOrigin;
  }

  void onRescheduleLongPressEnd(LongPressEndDetails _) {
    _runningUpdatePositionLoopDirection = LoopDirection.none;
    if (_didMove && widget.canUpdatePositionTo(_currentPosition)) {
      if (widget.canUpdatePositionTo(_currentPosition)) {
        widget.onUpdatePositionEnd(_currentPosition);
        _resetCurrentPosition();
      }
    } else {
      onRescheduleLongPressCancel();
    }
  }

  void onRescheduleLongPressCancel() {
    _runningUpdatePositionLoopDirection = LoopDirection.none;
    widget.onUpdatePositionCancel();
    _resetCurrentPosition();
  }

  void _tryToPerformRescheduleIncrementBy(double value) {
    final localCurrentTop = _currentPosition.top;
    final newTop = localCurrentTop + value;
    final newPosition = _currentPosition.withNewTop(newTop);
    final inherited = DayScheduleListInherited.of(context);
    if (inherited.newSchedulePositionIsOnMaxVisibleTop(
        newPosition, _currentPosition)) {
      if (_runningUpdatePositionLoopDirection != LoopDirection.top) {
        _runningUpdatePositionLoopDirection = LoopDirection.top;
        _runUpdatePositionLoop(
          newTop: newTop,
          newPosition: newPosition,
          increment: value,
          direction: LoopDirection.top,
        );
      }
    } else if (inherited.newSchedulePositionIsOnMaxVisibleBottom(
        newPosition, _currentPosition)) {
      if (_runningUpdatePositionLoopDirection != LoopDirection.bottom) {
        _runningUpdatePositionLoopDirection = LoopDirection.bottom;
        _runUpdatePositionLoop(
          newTop: newTop,
          newPosition: newPosition,
          increment: value,
          direction: LoopDirection.bottom,
        );
      }
    } else {
      _runningUpdatePositionLoopDirection = LoopDirection.none;
      if (widget.canUpdatePositionTo(newPosition)) {
        _updatePositionAndInform(newPosition);
      }
    }
  }

  void _runUpdatePositionLoop({
    required ScheduleItemPosition newPosition,
    required double newTop,
    required double increment,
    required LoopDirection direction,
  }) {
    var loopNewPosition = newPosition;
    var loopNewTop = newTop;
    Future.doWhile(() {
      if (widget.canUpdatePositionTo(loopNewPosition)) {
        _updatePositionAndInform(loopNewPosition);
        loopNewTop = loopNewTop + increment;
        loopNewPosition = _currentPosition.withNewTop(loopNewTop);
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => _runningUpdatePositionLoopDirection == direction,
        );
      } else {
        return false;
      }
    });
  }

  void _updatePositionAndInform(ScheduleItemPosition newPosition) {
    _currentPosition = newPosition;
    widget.onNewPositionUpdate(_currentPosition);
  }

  void _resetCurrentPosition() {
    _currentPosition = widget.position;
  }

  bool _verifyShouldContinueLoop(
      {required LoopDirection direction, required double currentOffset}) {
    bool keepRunning = _runningUpdatePositionLoopDirection == direction;
    if (direction == LoopDirection.top) {
      keepRunning = keepRunning && currentOffset <= 0;
    } else if (direction == LoopDirection.bottom) {
      keepRunning = keepRunning && currentOffset <= 0;
    }
    return keepRunning;
  }
}

enum LoopDirection { top, bottom, none }
