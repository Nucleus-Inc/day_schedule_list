import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_inherited.dart';
import 'package:flutter/material.dart';

import 'time_of_day_text.dart';

class TimeOfDayWidget extends StatelessWidget {
  const TimeOfDayWidget({
    required this.scheduleTime,
    required this.height,
    Key? key,
  }) : super(key: key);

  final double height;
  final ScheduleTimeOfDay scheduleTime;

  @override
  Widget build(BuildContext context) {
    final Color? timeOfDayText = DayScheduleListInherited.of(context).timeOfDayColor;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TimeOfDayText(
            time: scheduleTime.time,
            availability: scheduleTime.availability,
            color: timeOfDayText,
            context: context,
          ),
          const SizedBox(
            width: 8,
          ),
          const Expanded(
            child: Divider(),
          ),
        ],
      ),
    );
  }
}