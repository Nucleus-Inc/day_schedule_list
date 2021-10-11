import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/drag_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CanUpdateToHeight = bool Function(double);
typedef UpdateCallback = void Function();
typedef UpdateHeightCallback = void Function(double height);

class DynamicHeightContainer extends StatefulWidget {
  const DynamicHeightContainer(
      {required this.canUpdateHeightTo,
      required this.currentHeight,
      required this.child,
      this.dragIndicatorColor,
      this.dragIndicatorBorderColor,
      this.dragIndicatorBorderWidth,
      this.updateStep,
      this.onUpdateStart,
      this.onNewUpdate,
      this.onUpdateEnd,
      this.onUpdateCancel,
      Key? key})
      : assert(
          dragIndicatorBorderWidth == null || dragIndicatorBorderWidth > 0,
          'dragIndicatorBorderWidth must be null or > 0',
        ),
        assert(
          updateStep == null || updateStep > 0,
          'updateStep must be > 0',
        ),
        super(key: key);

  ///The widget that will have it's height changed.
  final Widget child;

  ///The color to be applied to the default drag indicator widget.
  final Color? dragIndicatorColor;

  ///The color to be applied to the default drag indicator widget border.
  final Color? dragIndicatorBorderColor;

  ///The width to be applied to the default drag indicator widget border.
  final double? dragIndicatorBorderWidth;

  ///How much [child] height should change by each update during vertical drag gesture.
  final double? updateStep;

  ///Current height of [child].
  final double currentHeight;

  ///Callback called when height update action starts.
  final UpdateCallback? onUpdateStart;

  ///Callback called everytime height value changes.
  final UpdateHeightCallback? onNewUpdate;

  ///Callback called when height update action ends
  final UpdateHeightCallback? onUpdateEnd;

  ///Callback called when height update action ends
  final UpdateCallback? onUpdateCancel;

  ///Function to determine if [child] height should or not change to a new one.
  final CanUpdateToHeight canUpdateHeightTo;

  @override
  _DynamicHeightContainerState createState() => _DynamicHeightContainerState();
}

class _DynamicHeightContainerState extends State<DynamicHeightContainer> {
  ///Current widget height
  late ValueNotifier<double> _currentHeight;

  ///The sum of last vertical drag gesture [DragUpdateDetails.delta.dy]  that does not
  ///caused View height to change because it is less than [widget.updateStep]
  double _pendingDeltaYForUpdateStep = 0;
  Offset _oldOffsetFromOrigin = Offset.zero;
  bool _didMove = false;

  @override
  void initState() {
    _currentHeight = ValueNotifier(widget.currentHeight);
    super.initState();
  }

  @override
  void dispose() {
    _currentHeight.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DynamicHeightContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentHeight.value = widget.currentHeight;
  }

  @override
  Widget build(BuildContext context) {
    return DragIndicatorWidget.bottom(
      onLongPressDown: onLongPressDown,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      dragIndicatorColor: widget.dragIndicatorColor,
      dragIndicatorBorderColor: widget.dragIndicatorBorderColor,
      dragIndicatorBorderWidth: widget.dragIndicatorBorderWidth,
      child: ValueListenableBuilder<double>(
        valueListenable: _currentHeight,
        builder: (context, value, child) {
          return SizedBox(
            height: value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }

  void onLongPressDown() {
    HapticFeedback.heavyImpact();
    _pendingDeltaYForUpdateStep = 0;
    _oldOffsetFromOrigin = Offset.zero;
    _didMove = false;
  }

  void onLongPressStart(LongPressStartDetails details) {
    _informUpdateStart();
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _didMove = true;
    double? updateStep = widget.updateStep;
    final offsetY = details.offsetFromOrigin.dy - _oldOffsetFromOrigin.dy;
    if (updateStep != null) {
      final double nextPendingIncrement = _pendingDeltaYForUpdateStep + offsetY;
      if (nextPendingIncrement.abs() >= updateStep) {
        _performIncrementBy(
          updateStep * (nextPendingIncrement / nextPendingIncrement.abs()),
        );
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
      _informUpdateEnd();
    } else {
      onLongPressCancel();
    }
  }

  void onLongPressCancel() {
    debugPrint('cancel');
    _informUpdateCancel();
  }

  void _informUpdateStart() {
    if (widget.onUpdateStart != null) {
      widget.onUpdateStart!();
    }
  }

  void _informUpdateEnd() {
    if (widget.onUpdateEnd != null) {
      widget.onUpdateEnd!(_currentHeight.value);
    }
  }

  void _informNewUpdate() {
    if (widget.onNewUpdate != null) {
      widget.onNewUpdate!(_currentHeight.value);
    }
  }

  void _informUpdateCancel() {
    if (widget.onUpdateCancel != null) {
      widget.onUpdateCancel!();
    }
  }

  void _performIncrementBy(double value) {
    final localCurrentHeight = _currentHeight.value;
    final finalHeight = localCurrentHeight + value;
    if (widget.canUpdateHeightTo(finalHeight)) {
      _currentHeight.value = finalHeight;
      _informNewUpdate();
    }
  }
}
