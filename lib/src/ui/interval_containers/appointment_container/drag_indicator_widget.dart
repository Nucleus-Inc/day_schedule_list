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
  })  : mode = _Mode.top,
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
  })  : mode = _Mode.bottom,
        super(key: key);

  const DragIndicatorWidget.overlayTop({
    this.dragIndicatorBorderColor,
    this.dragIndicatorBorderWidth,
    this.dragIndicatorColor,
    Key? key,
  })  : enabled = true,
        mode = _Mode.overlayTop,
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
        mode = _Mode.overlayBottom,
        onLongPressDown = null,
        onLongPressStart = null,
        onLongPressMoveUpdate = null,
        onLongPressEnd = null,
        super(key: key);

  final _Mode mode;
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
    final isTop = [_Mode.top, _Mode.overlayTop].contains(mode);
    final isBottom = [_Mode.bottom, _Mode.overlayBottom].contains(mode);
    final isOverlay = [_Mode.overlayBottom, _Mode.overlayTop].contains(mode);

    final Widget indicatorWidget = _buildContainer(
      context: context,
      isBottom: isBottom,
    );

    return Positioned(
      top: isTop ? -2 : null,
      right: isBottom ? 0 : null,//0,
      left: isTop ? 0 : null,//0,
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

  Widget _buildContainer({required BuildContext context, required bool isBottom,}) {

    return Container(
      alignment: isBottom
          ? Alignment.bottomRight
          : Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(
        top: isBottom
            ? 10
            : 0,
        bottom: isBottom
            ? 0
            : 10,
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

enum _Mode { top, bottom, overlayTop, overlayBottom }
