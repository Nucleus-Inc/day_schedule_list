import 'package:flutter/material.dart';

import 'time_of_day_widget.dart';

class TimeOfDayText extends Text {
  TimeOfDayText(
      {required TimeOfDay time,
      required BuildContext context,
      TimeOfDayAvailability availability = TimeOfDayAvailability.available,
      Color? color,
      Key? key,})
      : super(
          time.format(context),
          style: color != null
              ? Theme.of(context).textTheme.caption?.copyWith(
                    color: color,
                  )
              : (availability == TimeOfDayAvailability.available
                  ? Theme.of(context).textTheme.caption
                  : Theme.of(context).textTheme.caption?.copyWith(
                        color: Colors.grey.shade400,
                      )),
          key: key,
        );
}
