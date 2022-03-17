import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_inherited.dart';
import 'package:flutter/material.dart';

import 'time_of_day_widget.dart';
import '../helpers/time_of_day_extensions.dart';

class ValidTimeOfDayListWidget extends StatelessWidget {
  static const double baseInsetVertical = 20;

  const ValidTimeOfDayListWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inherited = DayScheduleListInherited.of(context);
    final List<ScheduleTimeOfDay> validTimesList = inherited.validTimesList;
    final double timeOfDayWidgetHeight = inherited.timeOfDayWidgetHeight;

    List<Widget> items = [];
    for (var index = 0; index < validTimesList.length; index++) {
      final hasNextItem = index < validTimesList.length - 1;
      final ScheduleTimeOfDay scheduleTime = validTimesList[index];
      final item = TimeOfDayWidget(
        scheduleTime: scheduleTime,
        height: timeOfDayWidgetHeight,
      );
      if (hasNextItem) {
        final nextTime = validTimesList[index + 1];
        final spaceBetween = calculateSpaceBetween(
          context: context,
          currentTime: scheduleTime,
          nextTime: nextTime,
        );
        if (spaceBetween >= 0) {
          items.addAll([
            item,
            SizedBox(
              height: spaceBetween,
            ),
          ]);
        }
      } else {
        items.add(item);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: baseInsetVertical,
        ),
        ...items,
        const SizedBox(
          height: baseInsetVertical,
        ),
      ],
    );
  }

  double calculateSpaceBetween({
    required BuildContext context,
    required ScheduleTimeOfDay currentTime,
    required ScheduleTimeOfDay nextTime,
  }) {
    final inherited = DayScheduleListInherited.of(context);

    final MinuteInterval minimumMinuteInterval =
        inherited.minimumMinuteInterval;
    final double minimumMinuteIntervalHeight =
        inherited.minimumMinuteIntervalHeight;
    final double timeOfDayWidgetHeight = inherited.timeOfDayWidgetHeight;

    final timeInMinutes = currentTime.time.toMinutes;
    final nextTimeInMinutes = nextTime.time.toMinutes;
    final intervalInMinutes = nextTimeInMinutes - timeInMinutes;
    final numberOfStepsBetween =
        intervalInMinutes / minimumMinuteInterval.numberValue;
    return numberOfStepsBetween * minimumMinuteIntervalHeight -
        timeOfDayWidgetHeight;
  }
}
