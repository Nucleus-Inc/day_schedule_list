import 'package:flutter/material.dart';

class DragIndicatorWidget extends StatelessWidget {
  const DragIndicatorWidget.top({
    required this.enabled,
    required this.onLongPressDown,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onLongPressMoveUpdate,
    this.dragIndicatorBorderColor,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    Key? key,
  })  : mode = _DragIndicatorMode.top,
        super(key: key);

  const DragIndicatorWidget.bottom({
    required this.enabled,
    required this.onLongPressDown,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onLongPressMoveUpdate,
    this.dragIndicatorBorderColor,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    Key? key,
  })  : mode = _DragIndicatorMode.bottom,
        super(key: key);

  const DragIndicatorWidget.overlayTop({
    this.dragIndicatorBorderColor,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    Key? key,
  })  : enabled = true,
        mode = _DragIndicatorMode.overlayTop,
        onLongPressDown = null,
        onLongPressStart = null,
        onLongPressMoveUpdate = null,
        onLongPressEnd = null,
        super(key: key);

  const DragIndicatorWidget.overlayBottom({
    this.dragIndicatorBorderColor,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    Key? key,
  })  : enabled = true,
        mode = _DragIndicatorMode.overlayBottom,
        onLongPressDown = null,
        onLongPressStart = null,
        onLongPressMoveUpdate = null,
        onLongPressEnd = null,
        super(key: key);

  final _DragIndicatorMode mode;
  final bool enabled;
  final GestureLongPressCallback? onLongPressDown;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressEndCallback? onLongPressEnd;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;

  ///The color to be applied to the default drag indicator widget.
  final Color? dragIndicatorColor;

  ///The color to be applied to the default drag indicator widget border.
  final Color? dragIndicatorBorderColor;

  ///The width to be applied to the default drag indicator widget border.
  final double? dragIndicatorBorderWidth;

  @override
  Widget build(BuildContext context) {
    final isTop =
        [_DragIndicatorMode.top, _DragIndicatorMode.overlayTop].contains(mode);
    final isBottom = [
      _DragIndicatorMode.bottom,
      _DragIndicatorMode.overlayBottom
    ].contains(mode);
    final isOverlay = [
      _DragIndicatorMode.overlayBottom,
      _DragIndicatorMode.overlayTop
    ].contains(mode);

    final Widget indicatorWidget = isBottom
        ? _IndicatorWidget.bottom(
            dragIndicatorBorderColor: dragIndicatorBorderColor,
            dragIndicatorBorderWidth: dragIndicatorBorderWidth,
            dragIndicatorColor: dragIndicatorColor,
          )
        : _IndicatorWidget.top(
            dragIndicatorBorderColor: dragIndicatorBorderColor,
            dragIndicatorBorderWidth: dragIndicatorBorderWidth,
            dragIndicatorColor: dragIndicatorColor,
          );

    return Positioned(
      top: isTop ? -2 : null,
      right: isBottom ? 0 : null, //0,
      left: isTop ? 0 : null, //0,
      width: 100,
      bottom: isBottom ? -2 : null,
      child: isOverlay
          ? indicatorWidget
          : AnimatedOpacity(
              opacity: enabled ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onLongPress: enabled ? onLongPressDown : null,
                onLongPressStart: enabled ? onLongPressStart : null,
                onLongPressEnd: enabled ? onLongPressEnd : null,
                onLongPressMoveUpdate: enabled ? onLongPressMoveUpdate : null,
                behavior: HitTestBehavior.opaque,
                child: indicatorWidget,
              ),
            ),
    );
  }
}

enum _DragIndicatorMode { top, bottom, overlayTop, overlayBottom }

class _IndicatorWidget extends StatelessWidget {
  const _IndicatorWidget.bottom({
    required this.dragIndicatorBorderColor,
    required this.dragIndicatorBorderWidth,
    required this.dragIndicatorColor,
    Key? key,
  })  : _mode = _IndicatorMode.bottom,
        super(key: key);

  const _IndicatorWidget.top({
    required this.dragIndicatorBorderColor,
    required this.dragIndicatorBorderWidth,
    required this.dragIndicatorColor,
    Key? key,
  })  : _mode = _IndicatorMode.top,
        super(key: key);

  final Color? dragIndicatorColor;
  final Color? dragIndicatorBorderColor;
  final double? dragIndicatorBorderWidth;

  final _IndicatorMode _mode;

  bool get isBottom => _mode == _IndicatorMode.bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isBottom ? Alignment.bottomRight : Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(
        top: isBottom ? 10 : 0,
        bottom: isBottom ? 0 : 10,
      ),
      child: Container(
        clipBehavior: Clip.hardEdge,
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dragIndicatorColor ?? Colors.white,
            border: Border.all(
              color: dragIndicatorBorderColor ?? Theme.of(context).primaryColor,
              width: dragIndicatorBorderWidth ?? 3,
            ),
            boxShadow: const [
              BoxShadow(
                offset: Offset(1, 1),
                blurRadius: 1,
                color: Colors.black45,
              )
            ]),
      ),
    );
  }
}

enum _IndicatorMode { top, bottom }
