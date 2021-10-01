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
      onVerticalDragDown: onVerticalDragDown,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragEnd: onVerticalDragEnd,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragCancel: onVerticalDragCancel,
      child: widget.child,
    );
  }

  void onVerticalDragDown(DragDownDetails details) {
    HapticFeedback.heavyImpact();
    if(widget.onUpdateStart != null) {
      widget.onUpdateStart!();
    }
  }

  void onVerticalDragStart(DragStartDetails details) {}

  void onVerticalDragUpdate(DragUpdateDetails details) {
    double? updateStep = widget.updateStep;
    if (updateStep != null) {
      final double nextPendingIncrement =
          _pendingDeltaYForUpdateStep + details.delta.dy;
      if (nextPendingIncrement.abs() >= updateStep) {
        _performIncrementBy(
            updateStep * (nextPendingIncrement / nextPendingIncrement.abs()));
        _pendingDeltaYForUpdateStep = 0;
      } else {
        _pendingDeltaYForUpdateStep = nextPendingIncrement;
      }
    } else {
      _performIncrementBy(details.delta.dy);
    }
  }

  void onVerticalDragEnd(DragEndDetails details) {
    if(widget.canUpdateTopTo(_currentTop)) {
      widget.onUpdateEnd(_currentTop);
    }
  }

  void onVerticalDragCancel(){
    if(widget.onUpdateCancel != null) {
      widget.onUpdateCancel!();
    }
  }

  void _performIncrementBy(double value) {
    final localCurrentTop = _currentTop;
    final finalTop = localCurrentTop + value;
    if(widget.canUpdateTopTo(finalTop)) {
      _currentTop = finalTop;
      widget.onNewUpdate(_currentTop);
    }
  }
}
