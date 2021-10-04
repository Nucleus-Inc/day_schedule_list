import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:flutter/material.dart';

class MyAppointment extends IntervalRange {
  MyAppointment({
    required this.title,
    required TimeOfDay start,
    required TimeOfDay end,
  }) : super(
          start: start,
          end: end,
        );

  final String title;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double heightOne = 120;
  double heightTwo = 180;
  double heightThree = 200;

  GlobalKey keyOne = GlobalKey();
  GlobalKey keyTwo = GlobalKey();
  GlobalKey keyThree = GlobalKey();

  final List<MyAppointment> myAppointments = [
    MyAppointment(
      title: 'Appointment 1',
      start: const TimeOfDay(hour: 8, minute: 40),
      end: const TimeOfDay(hour: 9, minute: 40),
    ),
    MyAppointment(
      title: 'Appointment 2',
      start: const TimeOfDay(hour: 11, minute: 0),
      end: const TimeOfDay(hour: 12, minute: 0),
    ),
    MyAppointment(
      title: 'Appointment 3',
      start: const TimeOfDay(hour: 14, minute: 15),
      end: const TimeOfDay(hour: 15, minute: 0),
    ),
    MyAppointment(
      title: 'Appointment 4',
      start: const TimeOfDay(hour: 16, minute: 10),
      end: const TimeOfDay(hour: 17, minute: 20),
    ),
    // MyAppointment(
    //   title: 'Appointment 1',
    //   start: const TimeOfDay(hour: 8, minute: 40),
    //   end: const TimeOfDay(hour: 9, minute: 40),
    // ),
    // MyAppointment(
    //   title: 'Appointment 1',
    //   start: const TimeOfDay(hour: 8, minute: 40),
    //   end: const TimeOfDay(hour: 9, minute: 40),
    // )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Teste'),
        ),
        body: DayScheduleListWidget<MyAppointment>(
          hourHeight: 100,
          referenceDate: DateTime.now(),
          appointments: myAppointments,
          updateAppointDuration: _updateAppointmentDuration,
          appointmentBuilder: _buildItem,
          unavailableIntervals: [
            IntervalRange(
                start: const TimeOfDay(hour: 0, minute: 0),
                end: const TimeOfDay(hour: 8, minute: 30)),
            IntervalRange(
                start: const TimeOfDay(hour: 12, minute: 0),
                end: const TimeOfDay(hour: 13, minute: 15)),
            IntervalRange(
                start: const TimeOfDay(hour: 18, minute: 0),
                end: const TimeOfDay(hour: 23, minute: 59))
          ],
        ));
  }

  Widget _buildItem(BuildContext context, MyAppointment appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 1,
      ),
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          appointment.title,
          style: Theme.of(context).textTheme.caption?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }

  Future<bool> _updateAppointmentDuration(
      MyAppointment appointment, IntervalRange newInterval) {
    setState(() {
      appointment.start = newInterval.start;
      appointment.end = newInterval.end;
    });

    ///Save on server or locally the change and inform the success or not
    return Future.value(true);
  }
}
