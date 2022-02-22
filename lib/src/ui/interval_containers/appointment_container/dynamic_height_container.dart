import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/drag_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CanUpdateToHeight = bool Function(double, HeightUpdateFrom);
typedef UpdateCallback = void Function(HeightUpdateFrom from);
typedef UpdateHeightCallback = void Function(
    double height, HeightUpdateFrom from,);

class DynamicHeightContainer extends StatefulWidget {
  const DynamicHeightContainer(
      {required this.editionEnabled,
      required this.canUpdateHeightTo,
      required this.onUpdateStart,
      required this.onNewUpdate,
      required this.onUpdateEnd,
      required this.onUpdateCancel,
      required this.currentHeight,
      required this.child,
      this.dragIndicatorColor,
      this.dragIndicatorBorderColor,
      this.dragIndicatorBorderWidth,
      this.updateStep,
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
  final UpdateCallback onUpdateStart;

  ///Callback called everytime height value changes.
  final UpdateHeightCallback onNewUpdate;

  ///Callback called when height update action ends
  final UpdateHeightCallback onUpdateEnd;

  ///Callback called when height update action ends
  final UpdateCallback onUpdateCancel;

  ///Function to determine if [child] height should or not change to a new one.
  final CanUpdateToHeight canUpdateHeightTo;

  final bool editionEnabled;
  @override
  _DynamicHeightContainerState createState() => _DynamicHeightContainerState();
}

class _DynamicHeightContainerState extends State<DynamicHeightContainer> {
  ///Current widget height
  late double _currentHeight;

  ///The sum of last vertical drag gesture [DragUpdateDetails.delta.dy]  that does not
  ///caused View height to change because it is less than [widget.updateStep]
  double _pendingDeltaYForUpdateStep = 0;
  Offset _oldOffsetFromOrigin = Offset.zero;
  bool _didMove = false;
  HeightUpdateFrom? _updateFrom;
  @override
  void initState() {
    _currentHeight = widget.currentHeight;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicHeightContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentHeight = widget.currentHeight;
    _updateFrom = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: _currentHeight,
          child: widget.child,
        ),
        DragIndicatorWidget.top(
          enabled: widget.editionEnabled,
          onLongPressDown: () => onLongPressDown(HeightUpdateFrom.top),
          onLongPressStart: null,
          onLongPressEnd: onLongPressEnd,
          onLongPressMoveUpdate: onLongPressMoveUpdate,
          dragIndicatorColor: widget.dragIndicatorColor,
          dragIndicatorBorderColor: widget.dragIndicatorBorderColor,
          dragIndicatorBorderWidth: widget.dragIndicatorBorderWidth,
        ),
        DragIndicatorWidget.bottom(
          enabled: widget.editionEnabled,
          onLongPressDown: () => onLongPressDown(HeightUpdateFrom.bottom),
          onLongPressStart: null,
          onLongPressEnd: onLongPressEnd,
          onLongPressMoveUpdate: onLongPressMoveUpdate,
          dragIndicatorColor: widget.dragIndicatorColor,
          dragIndicatorBorderColor: widget.dragIndicatorBorderColor,
          dragIndicatorBorderWidth: widget.dragIndicatorBorderWidth,
        ),
      ],
    );
  }

  void onLongPressDown(HeightUpdateFrom from) {
    HapticFeedback.heavyImpact();
    _pendingDeltaYForUpdateStep = 0;
    _oldOffsetFromOrigin = Offset.zero;
    _didMove = false;
    _updateFrom = from;
    _informUpdateStart();
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    double? updateStep = widget.updateStep;
    final offsetY = details.offsetFromOrigin.dy - _oldOffsetFromOrigin.dy;
    if (updateStep != null) {
      final double nextPendingIncrement = _pendingDeltaYForUpdateStep + offsetY;
      if (nextPendingIncrement.abs() >= updateStep) {
        _didMove = true;
        _performIncrementBy(
          updateStep * (nextPendingIncrement / nextPendingIncrement.abs()),
        );
        _pendingDeltaYForUpdateStep = 0;
      } else {
        _pendingDeltaYForUpdateStep = nextPendingIncrement;
      }
    } else {
      _didMove = true;
      _performIncrementBy(offsetY);
    }
    _oldOffsetFromOrigin = details.offsetFromOrigin;
  }

  void onLongPressEnd(LongPressEndDetails _) {
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
    final from = _updateFrom;
    if (from != null) {
      widget.onUpdateStart(from);
    }
  }

  void _informUpdateEnd() {
    final from = _updateFrom;
    if (from != null) {
      widget.onUpdateEnd(_currentHeight, from);
    }
  }

  void _informNewUpdate() {
    final from = _updateFrom;
    if (from != null) {
      widget.onNewUpdate(_currentHeight, from);
    }
  }

  void _informUpdateCancel() {
    final from = _updateFrom;
    if (from != null) {
      widget.onUpdateCancel(from);
    }
  }

  void _performIncrementBy(double value) {
    final from = _updateFrom;
    if (from != null) {
      final localCurrentHeight = _currentHeight;
      final finalHeight = localCurrentHeight +
          value * (from == HeightUpdateFrom.bottom ? 1 : -1);
      if (widget.canUpdateHeightTo(finalHeight, from)) {
        _currentHeight = finalHeight;
        _informNewUpdate();
      }
    }
  }
}

enum HeightUpdateFrom { top, bottom }
