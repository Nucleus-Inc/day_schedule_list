import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_container.dart';
import 'package:day_schedule_list/src/ui/interval_containers/unavailable_interval_container.dart';
import 'package:day_schedule_list/src/ui/valid_time_of_day_list_widget.dart';
import 'package:flutter/material.dart';

class DayScheduleListStack extends StatelessWidget {
  const DayScheduleListStack({
    required this.link,
    required this.validTimesListColumnKey,
    required this.internalUnavailableIntervals,
    required this.appointments,
    this.onTapUpOnDayScheduleList,
    Key? key,
  }) : super(key: key);

  final GlobalKey validTimesListColumnKey;
  final LayerLink link;
  final GestureTapUpCallback? onTapUpOnDayScheduleList;
  final List<UnavailableIntervalContainer> internalUnavailableIntervals;
  final List<AppointmentContainer> appointments;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        CompositedTransformTarget(
          link: link,
          child: ValidTimeOfDayListWidget(
            key: validTimesListColumnKey,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: onTapUpOnDayScheduleList,
            child: Container(),
          ),
        ),
        const Positioned(
          top: 0,
          left: 35,
          bottom: 0,
          child: VerticalDivider(),
        ),
        ...internalUnavailableIntervals,
        ...appointments,
      ],
    );
  }
}
