
import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/helpers/time_of_day_extensions.dart';
import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/appointment_update_controller.dart';

class ScheduleItemPositionUtils {
  static ScheduleItemPosition calculateItemRangePosition<T extends IntervalRange>({
    required T itemRange,
    required double insetVertical,
    required ScheduleTimeOfDay? firstValidTime,
    required double minimumMinuteIntervalHeight,
    required MinuteInterval minimumMinuteInterval,
  }) {
    final int deltaTop =
        itemRange.start.toMinutes - (firstValidTime?.time.toMinutes ?? 0);
    final deltaIntervalInMinutes = itemRange.deltaIntervalIMinutes;

    return ScheduleItemPosition(
      top: minimumMinuteIntervalHeight *
          (deltaTop / minimumMinuteInterval.numberValue) +
          insetVertical,
      height: minimumMinuteIntervalHeight *
          (deltaIntervalInMinutes / minimumMinuteInterval.numberValue),
    );
  }

  static double calculateOffsetIncrement({
  required ScheduleItemPosition oldPosition,
    required ScheduleItemPosition newPosition,
    required AppointmentUpdateMode updateMode,
}){
    double offsetIncrement = 0;
    if ([AppointmentUpdateMode.position, AppointmentUpdateMode.durationFromTop]
        .contains(updateMode)) {
      offsetIncrement = newPosition.top - oldPosition.top;
    } else {
      offsetIncrement = newPosition.height - oldPosition.height;
    }
    return offsetIncrement;
  }
}