import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:flutter/cupertino.dart';

class DayScheduleListInherited extends InheritedWidget {
  const DayScheduleListInherited({
    required Widget child,
    required this.validTimesList,
    required this.minimumMinuteIntervalHeight,
    required this.timeOfDayWidgetHeight,
    required this.minimumMinuteInterval,
    required this.timeOfDayColor,
    required this.dragIndicatorColor,
    required this.dragIndicatorBorderWidth,
    required this.dragIndicatorBorderColor,
    required this.customDragIndicator,
    this.allowEdition = false,
    Key? key,
  }) : super(
          child: child,
          key: key,
        );

  final List<ScheduleTimeOfDay> validTimesList;
  final double minimumMinuteIntervalHeight;
  final double timeOfDayWidgetHeight;
  final MinuteInterval minimumMinuteInterval;

  final Color? timeOfDayColor;
  final Color? dragIndicatorColor;
  final Color? dragIndicatorBorderColor;
  final double? dragIndicatorBorderWidth;
  final CustomDragIndicatorBuilder? customDragIndicator;

  final bool allowEdition;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static DayScheduleListInherited of(BuildContext context) {
    final DayScheduleListInherited? result =
        context.dependOnInheritedWidgetOfExactType<DayScheduleListInherited>();
    assert(result != null, 'No DayScheduleListInherited found in context');
    return result!;
  }
}
