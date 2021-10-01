import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CanUpdateToHeight = bool Function(double);
typedef OnScaleUpdate = bool Function(bool);

typedef UpdateCallback = void Function();
typedef UpdateHeightCallback = void Function(double height);

class DynamicHeightContainer extends StatefulWidget {
  const DynamicHeightContainer(
      {required this.canUpdateHeightTo,
      required this.currentHeight,
      required this.child,
      this.dragIconColor,
      this.dragIndicatorWidget,
      this.updateStep,
      this.onUpdateStart,
      this.onNewUpdate,
      this.onUpdateEnd,
      this.onUpdateCancel,
      Key? key})
      : assert(dragIndicatorWidget == null || dragIconColor == null,
            'dragIndicatorIcon == null or dragIconColor == null, never give value for both parameters'),
        assert(updateStep == null || updateStep > 0, 'updateStep must be > 0'),
        super(key: key);

  ///Custom widget to indicate the place to press for performing vertical drag gesture and
  ///Widget height change.
  final Widget? dragIndicatorWidget;

  ///The widget that will have it's height changed.
  final Widget child;

  ///The color to be applied to the default drag indicator widget.
  final Color? dragIconColor;

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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ValueListenableBuilder<double>(
          valueListenable: _currentHeight,
          builder: (context, value, child) {
            return SizedBox(
              height: value,
              child: child,
            );
          },
          child: widget.child,
        ),
        Positioned(
          right: 0,
          left: 0,
          bottom: -2,
          child: GestureDetector(
            onVerticalDragDown: onVerticalDragDown,
            onVerticalDragCancel: onVerticalDragCancel,
            onVerticalDragStart: onVerticalDragStart,
            onVerticalDragEnd: onVerticalDragEnd,
            onVerticalDragUpdate: onVerticalDragUpdate,
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: widget.dragIndicatorWidget ??
                  Container(
                    clipBehavior: Clip.hardEdge,
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.blue, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(1, 1),
                            blurRadius: 1,
                            color: Colors.black45,
                          )
                        ]),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  void onVerticalDragDown(DragDownDetails details) {
    debugPrint('down');
    HapticFeedback.heavyImpact();
    _informUpdateStart();
  }

  void onVerticalDragStart(DragStartDetails details) {
    debugPrint('start');
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    debugPrint('update');
    double? updateStep = widget.updateStep;
    if (updateStep != null) {
      final double nextPendingIncrement =
          _pendingDeltaYForUpdateStep + details.delta.dy;
      if (nextPendingIncrement.abs() >= updateStep) {
        _performIncrementBy(
          updateStep * (nextPendingIncrement / nextPendingIncrement.abs()),
        );
        _pendingDeltaYForUpdateStep = 0;
      } else {
        _pendingDeltaYForUpdateStep = nextPendingIncrement;
      }
    } else {
      _performIncrementBy(details.delta.dy);
    }
  }

  void onVerticalDragEnd(DragEndDetails details) {
    debugPrint('end');
    _informUpdateEnd();
  }

  void onVerticalDragCancel() {
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
