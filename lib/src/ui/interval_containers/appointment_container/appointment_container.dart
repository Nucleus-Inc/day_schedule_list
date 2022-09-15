import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_inherited.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/drag_indicator_widget.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppointmentContainer<S extends IntervalRange> extends StatefulWidget {
  const AppointmentContainer({
    required this.appointment,
    required this.position,
    required this.itemIndex,
    required this.callbackController,
    required this.child,
    this.optionalChildLine = const SizedBox.shrink(),
    this.optionalChildWidthLine = 0,
    Key? key,
  }) : super(key: key);

  final S appointment;
  final ScheduleItemPosition position;
  final int itemIndex;
  final Widget child;
  final num optionalChildWidthLine;
  final Widget? optionalChildLine;
  final AppointmentUpdateCallbackController callbackController;

  @override
  State<AppointmentContainer> createState() => _AppointmentContainerState();
}

class _AppointmentContainerState extends State<AppointmentContainer> {
  bool isEditing = false;
  late AppointmentUpdateController updateController;
  late ValueNotifier<bool> didMove;

  @override
  void initState() {
    didMove = ValueNotifier(false);
    super.initState();
  }

  @override
  void dispose() {
    didMove.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    updateController = AppointmentUpdateController(
      itemIndex: widget.itemIndex,
      updateStep:
          DayScheduleListInherited.of(context).minimumMinuteIntervalHeight,
      //error because calling this code inside initState
      originalPosition: widget.position,
      callbackController: widget.callbackController,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final inherited = DayScheduleListInherited.of(context);
    final double width = MediaQuery.of(context).size.width -
        (DayScheduleListWidget.intervalContainerLeftInset +
            5 +
            widget.optionalChildWidthLine);
    return Positioned(
      top: widget.position.top,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.only(
          left: DayScheduleListWidget.intervalContainerLeftInset,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: inherited.allowEdition ? _onTapToStartEditing : null,
                  onLongPress: isEditing
                      ? () => updateController.onLongPressDown(
                            AppointmentUpdateMode.position,
                            widget.appointment,
                          )
                      : null,
                  onLongPressEnd: isEditing ? _onLongPressEnd : null,
                  onLongPressMoveUpdate:
                      isEditing ? _onLongPressMoveUpdate : null,
                  child: Container(
                    height: widget.position.height,
                    constraints: BoxConstraints(
                      maxWidth: width,
                      minWidth: width,
                    ),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: didMove,
                      builder: (context, didMove, child) {
                        return Opacity(
                          opacity: didMove ? 0.7 : 1,
                          child: child!,
                        );
                      },
                      child: widget.child,
                    ),
                  ),
                ),
                DragIndicatorWidget.top(
                  enabled: isEditing,
                  onLongPressDown: () => updateController.onLongPressDown(
                    AppointmentUpdateMode.durationFromTop,
                    widget.appointment,
                  ),
                  onLongPressStart: null,
                  onLongPressEnd: _onLongPressEnd, //onLongPressEnd,
                  onLongPressMoveUpdate:
                      _onLongPressMoveUpdate, //onLongPressMoveUpdate,
                ),
                DragIndicatorWidget.bottom(
                  enabled: isEditing,
                  onLongPressDown: () => updateController.onLongPressDown(
                    AppointmentUpdateMode.durationFromBottom,
                    widget.appointment,
                  ),
                  onLongPressStart: null,
                  onLongPressEnd: _onLongPressEnd, //onLongPressEnd,
                  onLongPressMoveUpdate:
                      _onLongPressMoveUpdate, //onLongPressMoveUpdate,
                ),
              ],
            ),
            widget.optionalChildLine ?? Container()
          ],
        ),
      ),
    );
  }

  void _onTapToStartEditing() {
    HapticFeedback.selectionClick();
    setState(() => isEditing = !isEditing);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    didMove.value = true;
    updateController.onLongPressMoveUpdate(details);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    didMove.value = false;
    updateController.onLongPressEnd(details);
  }
}

typedef OnTapToStartEditing = void Function(ScheduleItemPosition);
