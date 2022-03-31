import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget_mixin.dart';
import 'package:flutter/material.dart';

import '../../models/interval_range.dart';
import '../../models/schedule_item_position.dart';
import '../day_schedule_list_widget.dart';

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
      left: DayScheduleListWidget.intervalContainerLeftInset,
      child: Container(
        height: position.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  static List<UnavailableIntervalContainer> buildList({
    required List<IntervalRange> unavailableIntervals,
    required ScheduleItemPosition Function(IntervalRange) calculatePosition,
  }) {
    return unavailableIntervals.map((IntervalRange interval) {
      return UnavailableIntervalContainer(
        interval: interval,
        position: calculatePosition(
          interval,
        ),
      );
    }).toList();
  }
}
