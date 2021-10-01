import 'package:flutter/material.dart';

import '../dynamic_height_container.dart';
import '../../models/schedule_item_position.dart';
import 'interval_container_position.dart';
import 'dynamic_position_container.dart';

class AppointmentContainer extends StatefulWidget {
  const AppointmentContainer({
    required this.position,
    required this.updateHeightStep,
    required this.canUpdateHeightTo,
    required this.onUpdateHeightEnd,
    required this.canUpdateTopTo,
    required this.onUpdateTopEnd,
    required this.child,
    Key? key,
  }) : super(key: key);

  final ScheduleItemPosition position;
  final Widget child;
  final double updateHeightStep;

  final CanUpdateToHeight canUpdateHeightTo;
  final Future<bool> Function(double newHeight) onUpdateHeightEnd;
  final CanUpdateToTopPosition canUpdateTopTo;
  final Future<bool> Function(double newTop) onUpdateTopEnd;

  @override
  _AppointmentContainerState createState() => _AppointmentContainerState();
}

class _AppointmentContainerState extends State<AppointmentContainer> {
  late ValueNotifier<ScheduleItemPosition> _currentPosition;
  late ValueNotifier<_AppointmentUpdatingMode> _updateMode;

  @override
  void initState() {
    _currentPosition = ValueNotifier(widget.position);
    _updateMode = ValueNotifier(_AppointmentUpdatingMode.none);
    super.initState();
  }

  @override
  void dispose() {
    _currentPosition.dispose();
    _updateMode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppointmentContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentPosition.value = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScheduleItemPosition>(
      valueListenable: _currentPosition,
      builder: (
        BuildContext context,
        ScheduleItemPosition position,
        Widget? child,
      ) {
        return IntervalContainerPosition(
          position: position,
          child: child!,
        );
      },
      child: DynamicTopPositionContainer(
        top: widget.position.top,
        canUpdateTopTo: widget.canUpdateTopTo,
        onNewUpdate: _onNewTopUpdate,
        onUpdateEnd: _onTopUpdateEnd,
        onUpdateStart: _onUpdateTopStart,
        onUpdateCancel: _onUpdateTopCancel,
        child: DynamicHeightContainer(
          currentHeight: widget.position.height,
          updateStep: widget.updateHeightStep,
          canUpdateHeightTo: widget.canUpdateHeightTo,
          onUpdateEnd: _onUpdateHeightEnd,
          onUpdateStart: _onUpdateHeightStart,
          onUpdateCancel: _onUpdateHeightCancel,
          child: ValueListenableBuilder<_AppointmentUpdatingMode>(
            valueListenable: _updateMode,
            builder: (context, value, child){
              return FractionallySizedBox(
                widthFactor: value == _AppointmentUpdatingMode.changeTop ? 1.02 : 1,
                child: widget.child,
              );
            },
          ),
        ),
      ),
    );
  }

  void _onUpdateTopStart(){
    if(_updateMode.value == _AppointmentUpdatingMode.none){
      _updateMode.value = _AppointmentUpdatingMode.changeTop;
    }
  }

  void _onNewTopUpdate(double newTop) {
    _currentPosition.value = _currentPosition.value.withNewTop(newTop);
  }

  void _onTopUpdateEnd(double newTop) async {
    _updateMode.value = _AppointmentUpdatingMode.none;
    final success = await widget.onUpdateTopEnd(newTop);
    _currentPosition.value = success ? _currentPosition.value.withNewTop(newTop) : widget.position;
  }

  void _onUpdateTopCancel(){
    _updateMode.value = _AppointmentUpdatingMode.none;
  }


  void _onUpdateHeightStart(){
    if(_updateMode.value == _AppointmentUpdatingMode.none){
      _updateMode.value = _AppointmentUpdatingMode.changeHeight;
    }
  }

  void _onUpdateHeightEnd(double newHeight) async {
    _updateMode.value = _AppointmentUpdatingMode.none;
    final success = await widget.onUpdateHeightEnd(newHeight);
    _currentPosition.value = success ? _currentPosition.value.withNewHeight(newHeight) : widget.position;
  }

  void _onUpdateHeightCancel(){
    _updateMode.value = _AppointmentUpdatingMode.none;
  }
}

enum _AppointmentUpdatingMode {
  changeTop, changeHeight, none
}