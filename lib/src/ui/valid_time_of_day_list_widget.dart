import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:flutter/material.dart';

import 'time_of_day_widget.dart';
import '../helpers/time_of_day_extensions.dart';

class ValidTimeOfDayListWidget extends StatelessWidget {
  static const double baseInsetVertical = 20;

  const ValidTimeOfDayListWidget({
    required this.validTimesList,
    required this.timeOfDayWidgetHeight,
    required this.minimumMinuteInterval,
    required this.minimumMinuteIntervalHeight,
    Key? key,
  }) : super(key: key);

  final List<ScheduleTimeOfDay> validTimesList;
  final double timeOfDayWidgetHeight;
  final MinuteInterval minimumMinuteInterval;
  final double minimumMinuteIntervalHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: baseInsetVertical,
        ),
        ..._buildTimeOfDayWidgetList(),
        const SizedBox(
          height: baseInsetVertical,
        ),
      ],
    );
  }

  List<Widget> _buildTimeOfDayWidgetList() {
    List<Widget> items = [];
    for (var index = 0; index < validTimesList.length; index++) {
      final hasNextItem = index < validTimesList.length - 1;
      final ScheduleTimeOfDay scheduleTime = validTimesList[index];
      final item = TimeOfDayWidget(
          scheduleTime: scheduleTime, height: timeOfDayWidgetHeight);
      if (hasNextItem) {
        final nextTime = validTimesList[index + 1];
        final timeInMinutes = scheduleTime.time.toMinutes;
        final nextTimeInMinutes = nextTime.time.toMinutes;
        final intervalInMinutes = nextTimeInMinutes - timeInMinutes;
        final numberOfStepsBetween =
            intervalInMinutes / minimumMinuteInterval.numberValue;
        final spaceBetween =
            numberOfStepsBetween * minimumMinuteIntervalHeight -
                timeOfDayWidgetHeight;
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
    return items;
  }
}
