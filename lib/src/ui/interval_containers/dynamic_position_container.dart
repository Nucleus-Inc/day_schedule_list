import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/drag_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CanUpdateToPosition = bool Function(ScheduleItemPosition);
typedef UpdatePositionCallback = void Function(ScheduleItemPosition position);

class DynamicTopPositionContainer extends StatefulWidget {
  const DynamicTopPositionContainer({
    required this.position,
    required this.child,
    required this.canUpdatePositionTo,
    required this.onUpdatePositionEnd,
    required this.onNewPositionUpdate,
    this.onUpdatePositionStart,
    this.onUpdatePositionCancel,
    this.updateStep,
    Key? key,
  }) : super(key: key);

  final ScheduleItemPosition position;

  final Widget child;

  ///How much [child] y axis should change by each update during vertical drag gesture.
  final double? updateStep;

  final CanUpdateToPosition canUpdatePositionTo;

  ///Callback called when top position update action starts
  final void Function()? onUpdatePositionStart;

  ///Callback called when top position update action ends
  final UpdatePositionCallback onUpdatePositionEnd;

  ///Callback called when top position update action ends
  final void Function()? onUpdatePositionCancel;

  ///Callback called when top position update action changes
  final UpdatePositionCallback onNewPositionUpdate;

  @override
  _DynamicTopPositionContainerState createState() =>
      _DynamicTopPositionContainerState();
}

class _DynamicTopPositionContainerState
    extends State<DynamicTopPositionContainer> {
  late ScheduleItemPosition _currentPosition;

  ///The sum of last vertical drag gesture [DragUpdateDetails.delta.dy]  that does not
  ///caused View top to change because it is less than [widget.updateStep]
  double _pendingDeltaYForUpdateStep = 0;
  Offset _oldOffsetFromOrigin = Offset.zero;
  bool _didMove = false;

  @override
  void initState() {
    _currentPosition = widget.position;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicTopPositionContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentPosition = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    return DragIndicatorWidget.top(
      onLongPressDown: onLongPressDown,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      child: GestureDetector(
        onLongPress: onRescheduleLongPressDown,
        onLongPressStart: onRescheduleLongPressStart,
        onLongPressEnd: onRescheduleLongPressEnd,
        onLongPressMoveUpdate: onRescheduleLongPressMoveUpdate,
        child: widget.child,
      ),
    );
  }


}

extension TopChanges on _DynamicTopPositionContainerState {
  void onLongPressDown() {
    HapticFeedback.heavyImpact();
  }

  void onLongPressStart(LongPressStartDetails details) {}

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {}

  void onLongPressEnd(LongPressEndDetails details) {}

  void onLongPressCancel() {}
}

extension RescheduleChanges on _DynamicTopPositionContainerState {
  void onRescheduleLongPressDown() {
    HapticFeedback.heavyImpact();
    _pendingDeltaYForUpdateStep = 0;
    _oldOffsetFromOrigin = Offset.zero;
    _didMove = false;
  }

  void onRescheduleLongPressStart(LongPressStartDetails details) {
    if (widget.onUpdatePositionStart != null) {
      widget.onUpdatePositionStart!();
    }
  }

  void onRescheduleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _didMove = true;
    double? updateStep = widget.updateStep;
    final offsetY = details.offsetFromOrigin.dy - _oldOffsetFromOrigin.dy;
    if (updateStep != null) {
      final double nextPendingIncrement = _pendingDeltaYForUpdateStep + offsetY;
      if (nextPendingIncrement.abs() >= updateStep) {
        _performRescheduleIncrementBy(
            updateStep * (nextPendingIncrement / nextPendingIncrement.abs()));
        _pendingDeltaYForUpdateStep = 0;
      } else {
        _pendingDeltaYForUpdateStep = nextPendingIncrement;
      }
    } else {
      _performRescheduleIncrementBy(offsetY);
    }
    _oldOffsetFromOrigin = details.offsetFromOrigin;
  }

  void onRescheduleLongPressEnd(LongPressEndDetails details) {
    if (_didMove) {
      debugPrint('end');
      if (widget.canUpdatePositionTo(_currentPosition)) {
        widget.onUpdatePositionEnd(_currentPosition);
      }
    } else {
      onRescheduleLongPressCancel();
    }
  }

  void onRescheduleLongPressCancel() {
    debugPrint('cancel');
    if (widget.onUpdatePositionCancel != null) {
      widget.onUpdatePositionCancel!();
    }
  }

  void _performRescheduleIncrementBy(double value) {
    final localCurrentTop = _currentPosition.top;
    final finalTop = localCurrentTop + value;
    final finalPosition = _currentPosition.withNewTop(finalTop);
    if (widget.canUpdatePositionTo(finalPosition)) {
      _currentPosition = finalPosition;
      widget.onNewPositionUpdate(_currentPosition);
    }
  }
}

mixin _DynamicPositionTopContainer {

}
