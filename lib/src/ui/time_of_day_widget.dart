import 'package:flutter/material.dart';

import 'time_of_day_text.dart';

class TimeOfDayWidget extends StatelessWidget {
  const TimeOfDayWidget(
      {required this.scheduleTime, required this.height, Key? key,})
      : super(key: key);

  final double height;
  final ScheduleTimeOfDay scheduleTime;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TimeOfDayText(
            time: scheduleTime.time,
            availability: scheduleTime.availability,
            context: context,
          ),
          const SizedBox(
            width: 8,
          ),
          const Expanded(
            child: Divider(),
          )
        ],
      ),
    );
  }
}

class ScheduleTimeOfDay {
  ScheduleTimeOfDay.available({required this.time})
      : availability = TimeOfDayAvailability.available;
  ScheduleTimeOfDay.unavailable({required this.time})
      : availability = TimeOfDayAvailability.unavailable;
  TimeOfDay time;
  TimeOfDayAvailability availability;
}

enum TimeOfDayAvailability { available, unavailable }
