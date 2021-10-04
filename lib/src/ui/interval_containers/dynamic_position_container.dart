import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CanUpdateToTopPosition = bool Function(double);
typedef UpdateTopPositionCallback = void Function(double top);

class DynamicTopPositionContainer extends StatefulWidget {
  const DynamicTopPositionContainer({
    required this.top,
    required this.child,
    required this.canUpdateTopTo,
    required this.onUpdateEnd,
    required this.onNewUpdate,
    this.onUpdateStart,
    this.onUpdateCancel,
    this.updateStep,
    Key? key,
  }) : super(key: key);

  final double top;

  final Widget child;

  ///How much [child] y axis should change by each update during vertical drag gesture.
  final double? updateStep;

  final CanUpdateToTopPosition canUpdateTopTo;

  ///Callback called when top position update action starts
  final void Function()? onUpdateStart;

  ///Callback called when top position update action ends
  final UpdateTopPositionCallback onUpdateEnd;

  ///Callback called when top position update action ends
  final void Function()? onUpdateCancel;

  ///Callback called when top position update action changes
  final UpdateTopPositionCallback onNewUpdate;

  @override
  _DynamicTopPositionContainerState createState() =>
      _DynamicTopPositionContainerState();
}

class _DynamicTopPositionContainerState
    extends State<DynamicTopPositionContainer> {
  late double _currentTop;

  ///The sum of last vertical drag gesture [DragUpdateDetails.delta.dy]  that does not
  ///caused View top to change because it is less than [widget.updateStep]
  double _pendingDeltaYForUpdateStep = 0;
  Offset _oldOffsetFromOrigin = Offset.zero;
  bool _didMove = false;

  @override
  void initState() {
    _currentTop = widget.top;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicTopPositionContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentTop = widget.top;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPressDown,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      child: widget.child,
    );
  }

  void onLongPressDown() {
    HapticFeedback.heavyImpact();
    _pendingDeltaYForUpdateStep = 0;
    _oldOffsetFromOrigin = Offset.zero;
    _didMove = false;
  }

  void onLongPressStart(LongPressStartDetails details) {
    if (widget.onUpdateStart != null) {
      widget.onUpdateStart!();
    }
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _didMove = true;
    double? updateStep = widget.updateStep;
    final offsetY = details.offsetFromOrigin.dy - _oldOffsetFromOrigin.dy;
    if (updateStep != null) {
      final double nextPendingIncrement = _pendingDeltaYForUpdateStep + offsetY;
      if (nextPendingIncrement.abs() >= updateStep) {
        _performIncrementBy(
            updateStep * (nextPendingIncrement / nextPendingIncrement.abs()));
        _pendingDeltaYForUpdateStep = 0;
      } else {
        _pendingDeltaYForUpdateStep = nextPendingIncrement;
      }
    } else {
      _performIncrementBy(offsetY);
    }
    _oldOffsetFromOrigin = details.offsetFromOrigin;
  }

  void onLongPressEnd(LongPressEndDetails details) {
    if (_didMove) {
      debugPrint('end');
      if (widget.canUpdateTopTo(_currentTop)) {
        widget.onUpdateEnd(_currentTop);
      }
    } else {
      onLongPressCancel();
    }
  }

  void onLongPressCancel() {
    debugPrint('cancel');
    if (widget.onUpdateCancel != null) {
      widget.onUpdateCancel!();
    }
  }

  // void onVerticalDragDown(DragDownDetails details) {
  //   HapticFeedback.heavyImpact();
  // }
  //
  // void onVerticalDragStart(DragStartDetails details) {
  //   if(widget.onUpdateStart != null) {
  //     widget.onUpdateStart!();
  //   }
  // }
  //
  // void onVerticalDragUpdate(DragUpdateDetails details) {
  //   double? updateStep = widget.updateStep;
  //   if (updateStep != null) {
  //     final double nextPendingIncrement =
  //         _pendingDeltaYForUpdateStep + details.delta.dy;
  //     if (nextPendingIncrement.abs() >= updateStep) {
  //       _performIncrementBy(
  //           updateStep * (nextPendingIncrement / nextPendingIncrement.abs()));
  //       _pendingDeltaYForUpdateStep = 0;
  //     } else {
  //       _pendingDeltaYForUpdateStep = nextPendingIncrement;
  //     }
  //   } else {
  //     _performIncrementBy(details.delta.dy);
  //   }
  // }
  //
  // void onVerticalDragEnd(DragEndDetails details) {
  //   if(widget.canUpdateTopTo(_currentTop)) {
  //     widget.onUpdateEnd(_currentTop);
  //   }
  // }
  //
  // void onVerticalDragCancel(){
  //   if(widget.onUpdateCancel != null) {
  //     widget.onUpdateCancel!();
  //   }
  // }

  void _performIncrementBy(double value) {
    final localCurrentTop = _currentTop;
    final finalTop = localCurrentTop + value;
    if (widget.canUpdateTopTo(finalTop)) {
      _currentTop = finalTop;
      widget.onNewUpdate(_currentTop);
    }
  }
}
