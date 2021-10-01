import 'package:day_schedule_list/shelf.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:flutter/material.dart';

import '../day_schedule_list.dart';
import 'appointment_container/appointment_time_of_day_indicator_widget.dart';

class AppointmentContainerOverlay extends StatefulWidget {
  const AppointmentContainerOverlay({
    required this.position,
    required this.interval,
    required this.link,
    required this.child,
    required this.timeIndicatorsInset,
    Key? key,
  }) : super(key: key);

  final ScheduleItemPosition position;
  final LayerLink link;
  final Widget child;
  final double timeIndicatorsInset;
  final IntervalRange interval;

  @override
  _AppointmentContainerOverlayState createState() =>
      _AppointmentContainerOverlayState();
}

class _AppointmentContainerOverlayState
    extends State<AppointmentContainerOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 5,
      child: CompositedTransformFollower(
        offset: Offset(0, widget.position.top),
        link: widget.link,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppointmentTimeOfDayIndicatorWidget.start(
              time: widget.interval.start,
              timeIndicatorsInset: widget.timeIndicatorsInset,
            ),
            AppointmentTimeOfDayIndicatorWidget.end(
              time: widget.interval.end,
              timeIndicatorsInset: widget.timeIndicatorsInset,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: DayScheduleList.intervalContainerLeftInset,
              ),
              child: SizedBox(
                width: double.infinity,
                height: widget.position.height,
                child: widget.child,
              ),
            )
          ],
        ),
      ),
    );
  }
}
