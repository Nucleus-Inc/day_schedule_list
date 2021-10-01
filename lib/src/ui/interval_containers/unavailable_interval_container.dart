import 'package:day_schedule_list/shelf.dart';
import 'package:flutter/material.dart';

import '../../models/interval_range.dart';
import '../../models/schedule_item_position.dart';

class UnavailableIntervalContainer extends StatelessWidget {
  const UnavailableIntervalContainer({
    required this.interval,
    required this.position,
    Key? key,
  }) : super(key: key);

  final IntervalRange interval;
  final ScheduleItemPosition position;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.top,
      right: 0,
      left: DayScheduleList.intervalContainerLeftInset,
      child: Container(
        height: position.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
