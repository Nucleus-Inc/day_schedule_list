import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/ui/time_of_day_widget.dart';
import 'package:flutter/cupertino.dart';

class DayScheduleListInherited extends InheritedWidget {
  const DayScheduleListInherited({
    required Widget child,
    required this.validTimesList,
    required this.minimumMinuteIntervalHeight,
    required this.timeOfDayWidgetHeight,
    required this.minimumMinuteInterval,
    required this.dragIndicatorColor,
    required this.dragIndicatorBorderWidth,
    required this.dragIndicatorBorderColor,
    Key? key,
  }) : super(
          child: child,
          key: key,
        );

  final List<ScheduleTimeOfDay> validTimesList;
  final double minimumMinuteIntervalHeight;
  final double timeOfDayWidgetHeight;
  final MinuteInterval minimumMinuteInterval;

  final Color? dragIndicatorColor;
  final Color? dragIndicatorBorderColor;
  final double? dragIndicatorBorderWidth;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

   static DayScheduleListInherited of(BuildContext context) {
     final DayScheduleListInherited? result = context.dependOnInheritedWidgetOfExactType<DayScheduleListInherited>();
     assert(result != null, 'No FrogColor found in context');
     return result!;
   }
}
