import 'package:flutter/material.dart';

class DragIndicatorWidget extends StatelessWidget {
  const DragIndicatorWidget.top({
    required this.onLongPressDown,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onLongPressMoveUpdate,
    this.dragIndicatorBorderColor,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    Key? key,
  })  : mode = _Mode.top,
        super(key: key);

  const DragIndicatorWidget.bottom({
    required this.onLongPressDown,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onLongPressMoveUpdate,
    this.dragIndicatorBorderColor,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    Key? key,
  })  : mode = _Mode.bottom,
        super(key: key);

  const DragIndicatorWidget.overlayTop({
    this.dragIndicatorBorderColor,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    Key? key,
  })  : mode = _Mode.overlayTop,
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
  })  : mode = _Mode.overlayBottom,
        onLongPressDown = null,
        onLongPressStart = null,
        onLongPressMoveUpdate = null,
        onLongPressEnd = null,
        super(key: key);

  final _Mode mode;
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
    final Widget indicatorWidget = _buildContainer(context);
    return Positioned(
      top: [_Mode.top, _Mode.overlayTop].contains(mode) ? -2 : null,
      right: 0,
      left: 0,
      bottom: [_Mode.bottom, _Mode.overlayBottom].contains(mode) ? -2 : null,
      child: [_Mode.overlayBottom, _Mode.overlayTop].contains(mode)
          ? indicatorWidget
          : GestureDetector(
              onLongPress: onLongPressDown,
              onLongPressStart: onLongPressStart,
              onLongPressEnd: onLongPressEnd,
              onLongPressMoveUpdate: onLongPressMoveUpdate,
              behavior: HitTestBehavior.opaque,
              child: indicatorWidget,
            ),
    );
  }

  Widget _buildContainer(BuildContext context) {
    return Container(
      alignment: [_Mode.bottom, _Mode.overlayBottom].contains(mode)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
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

enum _Mode { top, bottom, overlayTop, overlayBottom }
