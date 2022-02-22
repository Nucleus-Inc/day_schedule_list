import 'package:day_schedule_list/src/models/minute_interval.dart';

class UnavailableIntervalToAddAppointmentException implements Exception {
  UnavailableIntervalToAddAppointmentException(
      {required this.appointmentMinimumDuration});

  MinuteInterval appointmentMinimumDuration;

  @override
  String toString() {
    return 'It is not possible to create an appointment at this location, '
        'because the available time interval is less than '
        '${appointmentMinimumDuration.numberValue} minutes';
  }
}