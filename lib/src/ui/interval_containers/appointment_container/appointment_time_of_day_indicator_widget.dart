import 'package:flutter/material.dart';

import '../../time_of_day_text.dart';

enum _Kind { start, end }

class AppointmentTimeOfDayIndicatorWidget extends StatelessWidget {
  const AppointmentTimeOfDayIndicatorWidget.start({
    required this.time,
    required this.timeIndicatorsInset,
    Key? key,
  })  : kind = _Kind.start,
        super(key: key);

  const AppointmentTimeOfDayIndicatorWidget.end({
    required this.time,
    required this.timeIndicatorsInset,
    Key? key,
  })  : kind = _Kind.end,
        super(key: key);

  final TimeOfDay time;
  final double timeIndicatorsInset;
  final _Kind kind;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: kind == _Kind.start ? -1.0 * timeIndicatorsInset : null,
      bottom: kind == _Kind.end ? -1.0 * timeIndicatorsInset : null,
      left: 0,
      child: TimeOfDayText(
        time: time,
        context: context,
        color: Colors.red,
      ),
    );
  }
}
