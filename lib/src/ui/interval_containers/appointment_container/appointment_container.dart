import 'package:flutter/material.dart';

import '../../day_schedule_list_widget.dart';
import 'dynamic_height_container.dart';
import '../../../models/schedule_item_position.dart';
import 'dynamic_position_container.dart';

typedef AppointmentUpdatePositionStartCallback = void Function(
  AppointmentUpdatingMode mode,
);

class AppointmentContainer extends StatefulWidget {
  const AppointmentContainer({
    required this.position,
    required this.timeIndicatorsInset,
    required this.updateStep,
    required this.canUpdateHeightTo,
    required this.canUpdatePositionTo,
    required this.onUpdatePositionEnd,
    required this.onNewUpdatePosition,
    required this.onUpdatePositionStart,
    required this.onUpdatePositionCancel,
    required this.child,
    Key? key,
  }) : super(key: key);

  final ScheduleItemPosition position;
  final Widget child;
  final double updateStep;
  final double timeIndicatorsInset;

  final CanUpdateToHeight canUpdateHeightTo;

  final CanUpdateToPosition canUpdatePositionTo;
  final UpdatePositionCallback onUpdatePositionEnd;
  final UpdatePositionCallback onNewUpdatePosition;
  final AppointmentUpdatePositionStartCallback onUpdatePositionStart;
  final void Function() onUpdatePositionCancel;

  @override
  _AppointmentContainerState createState() => _AppointmentContainerState();
}

class _AppointmentContainerState extends State<AppointmentContainer> {
  late ValueNotifier<AppointmentUpdatingMode> _updateMode;
  late ValueNotifier<bool> _editingMode;
  @override
  void initState() {
    _editingMode = ValueNotifier(false);
    _updateMode = ValueNotifier(AppointmentUpdatingMode.none);
    super.initState();
  }

  @override
  void dispose() {
    _editingMode.dispose();
    _updateMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position.top,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.only(
          left: DayScheduleListWidget.intervalContainerLeftInset,
        ),
        child: DynamicPositionContainer(
          position: widget.position,
          updateStep: widget.updateStep,
          canUpdatePositionTo: widget.canUpdatePositionTo,
          onNewPositionUpdate: _onNewPositionUpdate,
          onUpdatePositionEnd: _onPositionUpdateEnd,
          onUpdatePositionCancel: _onUpdatePositionCancel,
          onUpdatePositionStart: _onUpdatePositionStart,
          onUpdateEditingModeTap: (editing) => _editingMode.value = editing,
          child: ValueListenableBuilder<bool>(
            valueListenable: _editingMode,
            builder: (
              context,
              editingMode,
              child,
            ) {
              return DynamicHeightContainer(
                editionEnabled: editingMode,
                currentHeight: widget.position.height,
                updateStep: widget.updateStep,
                canUpdateHeightTo: widget.canUpdateHeightTo,
                onUpdateEnd: _onUpdateHeightEnd,
                onUpdateStart: _onUpdateHeightStart,
                onUpdateCancel: _onUpdateHeightCancel,
                onNewUpdate: _onNewUpdateHeight,
                child: child!,
              );
            },
            child: ValueListenableBuilder<AppointmentUpdatingMode>(
              valueListenable: _updateMode,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value != AppointmentUpdatingMode.none ? 0.5 : 1,
                  child: child!,
                );
              },
              child: FractionallySizedBox(
                widthFactor: 1,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onUpdatePositionStart() {
    _updateModeTo(AppointmentUpdatingMode.changePosition);
    widget.onUpdatePositionStart(_updateMode.value);
  }

  void _onNewPositionUpdate(ScheduleItemPosition newPosition) {
    widget.onNewUpdatePosition(newPosition);
  }

  void _onPositionUpdateEnd(ScheduleItemPosition newPosition) {
    _updateModeToNoneFrom(AppointmentUpdatingMode.changePosition);
    widget.onUpdatePositionEnd(newPosition);
  }

  void _onUpdatePositionCancel() {
    _updateModeToNoneFrom(AppointmentUpdatingMode.changePosition);
    widget.onUpdatePositionCancel();
  }

  void _onUpdateHeightStart(HeightUpdateFrom from) {
    _updateModeTo(AppointmentUpdatingModeFromHeightUpdate.create(from));
    widget.onUpdatePositionStart(_updateMode.value);
  }

  void _onNewUpdateHeight(double newHeight, HeightUpdateFrom from) {
    widget.onNewUpdatePosition(_newPositionFor(newHeight, from));
  }

  void _onUpdateHeightEnd(double newHeight, HeightUpdateFrom from) async {
    _updateModeToNoneFrom(AppointmentUpdatingModeFromHeightUpdate.create(from));
    widget.onUpdatePositionEnd(_newPositionFor(newHeight, from));
  }

  void _onUpdateHeightCancel(HeightUpdateFrom from) {
    _updateModeToNoneFrom(AppointmentUpdatingModeFromHeightUpdate.create(from));
    widget.onUpdatePositionCancel();
  }

  void _updateModeTo(AppointmentUpdatingMode mode) {
    if (_updateMode.value == AppointmentUpdatingMode.none) {
      _updateMode.value = mode;
    }
  }

  void _updateModeToNoneFrom(AppointmentUpdatingMode mode) {
    if (_updateMode.value == mode) {
      _updateMode.value = AppointmentUpdatingMode.none;
    }
  }

  ScheduleItemPosition _newPositionFor(
    double newHeight,
    HeightUpdateFrom from,
  ) {
    switch (from) {
      case HeightUpdateFrom.top:
        final deltaHeight = newHeight - widget.position.height;
        final newTop = widget.position.top - deltaHeight;
        return ScheduleItemPosition(
          top: newTop,
          height: newHeight,
        );
      case HeightUpdateFrom.bottom:
        return widget.position.withNewHeight(newHeight);
    }
  }
}

enum AppointmentUpdatingMode {
  changePosition,
  changeHeight,
  changeTop,
  none,
}

extension AppointmentUpdatingModeFromHeightUpdate on AppointmentUpdatingMode {
  static AppointmentUpdatingMode create(HeightUpdateFrom from) {
    switch (from) {
      case HeightUpdateFrom.top:
        return AppointmentUpdatingMode.changeTop;
      case HeightUpdateFrom.bottom:
        return AppointmentUpdatingMode.changeHeight;
    }
  }
}
