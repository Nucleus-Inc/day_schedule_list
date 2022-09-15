import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _minimumMinuteIntervalAndAppointmentMinimumDurationAssertionsTest();
  _hourHeightAssertionsTest();
  _readOnlyTests();
}

void _minimumMinuteIntervalAndAppointmentMinimumDurationAssertionsTest(){
  group(
    'minimumMinuteInterval and AppointmentMinimumDuration assertions',
      (){
        testWidgets(
            'minimumMinuteInterval = MinuteInterval.fifteen and appointmentMinimumDuration = MinuteInterval.five',
                (WidgetTester tester) async {
              try {
                await tester.pumpWidget(DayScheduleListWidget<IntervalRange>(
                  minimumMinuteInterval: MinuteInterval.fifteen,
                  appointmentMinimumDuration: MinuteInterval.five,
                  unavailableIntervals: const [],
                  appointments: const [],
                  referenceDate: DateTime.now(),
                  createNewAppointmentAt: (IntervalRange? interval, DayScheduleListWidgetErrors? error) {  },
                  updateAppointDuration: (IntervalRange appointment, IntervalRange newInterval) {
                    return Future.value(true);
                  },
                  optionalChildLine: (context, appointment, height) {
                    return Container();
                  },
                  appointmentBuilder: (BuildContext context, IntervalRange appointment, double height) {
                    return Container();
                  },
                ));
              }
              catch(error) {
                expect(error, isAssertionError);
              }
            });
        testWidgets(
            'minimumMinuteInterval = MinuteInterval.fifteen and appointmentMinimumDuration = MinuteInterval.fifteen',
                (WidgetTester tester) async {
              dynamic error;
              try {

                await tester.pumpWidget(MaterialApp(
                  //data: const MediaQueryData(),
                  home: DayScheduleListWidget<IntervalRange>(
                    minimumMinuteInterval: MinuteInterval.fifteen,
                    appointmentMinimumDuration: MinuteInterval.fifteen,
                    unavailableIntervals: const [],
                    appointments: const [],
                    referenceDate: DateTime.now(),
                    createNewAppointmentAt: (IntervalRange? interval, DayScheduleListWidgetErrors? error) {  },
                    updateAppointDuration: (IntervalRange appointment, IntervalRange newInterval) {
                      return Future.value(true);
                    },
                    optionalChildLine: (context, appointment, height) {
                    return Container();
                  },
                    appointmentBuilder: (BuildContext context, IntervalRange appointment, double height) {
                      return Container();
                    },
                  ),
                ));
              }
              catch(e) {
                error = e;
              }
              expect(error, isNull);
            });

        testWidgets(
            'minimumMinuteInterval = MinuteInterval.fifteen and appointmentMinimumDuration = MinuteInterval.fifteen',
                (WidgetTester tester) async {
              dynamic error;
              try {
                await tester.pumpWidget(MaterialApp(
                  home: DayScheduleListWidget<IntervalRange>(
                    minimumMinuteInterval: MinuteInterval.fifteen,
                    appointmentMinimumDuration: MinuteInterval.thirty,
                    unavailableIntervals: const [],
                    appointments: const [],
                    referenceDate: DateTime.now(),
                    createNewAppointmentAt: (IntervalRange? interval, DayScheduleListWidgetErrors? error) {  },
                    updateAppointDuration: (IntervalRange appointment, IntervalRange newInterval) {
                      return Future.value(true);
                    },
                    optionalChildLine: (context, appointment, height) {
                    return Container();
                  },
                    appointmentBuilder: (BuildContext context, IntervalRange appointment, double height) {
                      return Container();
                    },
                  ),
                ));
              }
              catch(e) {
                error = e;
              }
              expect(error, isNull);
            });
      },
  );
}

void _hourHeightAssertionsTest(){
  group(
      'hourHeight assertions',
          () {
        testWidgets(
            'hourHeight < 0',
                (WidgetTester tester) async {
              try {
                await tester.pumpWidget(DayScheduleListWidget<IntervalRange>(
                  minimumMinuteInterval: MinuteInterval.fifteen,
                  appointmentMinimumDuration: MinuteInterval.fifteen,
                  hourHeight: -1,
                  unavailableIntervals: const [],
                  appointments: const [],
                  referenceDate: DateTime.now(),
                  createNewAppointmentAt: (IntervalRange? interval,
                      DayScheduleListWidgetErrors? error) {},
                  updateAppointDuration: (IntervalRange appointment,
                      IntervalRange newInterval) {
                    return Future.value(true);
                  },
                  optionalChildLine: (context, appointment, height) {
                    return Container();
                  },
                  appointmentBuilder: (BuildContext context,
                      IntervalRange appointment, double height) {
                    return Container();
                  },
                ));
              }
              catch (error) {
                expect(error, isAssertionError);
              }
            });
        testWidgets(
            'hourHeight = 0',
                (WidgetTester tester) async {
              try {
                await tester.pumpWidget(DayScheduleListWidget<IntervalRange>(
                  minimumMinuteInterval: MinuteInterval.fifteen,
                  appointmentMinimumDuration: MinuteInterval.fifteen,
                  hourHeight: 0,
                  unavailableIntervals: const [],
                  appointments: const [],
                  referenceDate: DateTime.now(),
                  createNewAppointmentAt: (IntervalRange? interval,
                      DayScheduleListWidgetErrors? error) {},
                  updateAppointDuration: (IntervalRange appointment,
                      IntervalRange newInterval) {
                    return Future.value(true);
                  },
                  optionalChildLine: (context, appointment, height) {
                    return Container();
                  },
                  appointmentBuilder: (BuildContext context,
                      IntervalRange appointment, double height) {
                    return Container();
                  },
                ));
              }
              catch (error) {
                expect(error, isAssertionError);
              }
            });
        testWidgets(
            'hourHeight > 0',
                (WidgetTester tester) async {
              dynamic error;
              try {
                await tester.pumpWidget(MaterialApp(
                  //data: const MediaQueryData(),
                  home: DayScheduleListWidget<IntervalRange>(
                    minimumMinuteInterval: MinuteInterval.fifteen,
                    appointmentMinimumDuration: MinuteInterval.fifteen,
                    hourHeight: 120,
                    unavailableIntervals: const [],
                    appointments: const [],
                    referenceDate: DateTime.now(),
                    createNewAppointmentAt: (IntervalRange? interval,
                        DayScheduleListWidgetErrors? error) {},
                    updateAppointDuration: (IntervalRange appointment,
                        IntervalRange newInterval) {
                      return Future.value(true);
                    },
                    optionalChildLine: (context, appointment, height) {
                    return Container();
                  },
                    appointmentBuilder: (BuildContext context,
                        IntervalRange appointment, double height) {
                      return Container();
                    },
                  ),
                ));
              }
              catch (e) {
                error = e;
              }
              expect(error, isNull);
            });
      }
  );
}

void _readOnlyTests(){
  group(
    'read only tests',
      (){
        testWidgets(
            'read only active',
                (WidgetTester tester) async {
                  final DayScheduleListWidgetGlobalKey key = DayScheduleListWidgetGlobalKey();
                  await tester.pumpWidget(MaterialApp(
                    home: DayScheduleListWidget<IntervalRange>(
                      minimumMinuteInterval: MinuteInterval.fifteen,
                      appointmentMinimumDuration: MinuteInterval.fifteen,
                      hourHeight: 120,
                      unavailableIntervals: const [],
                      appointments: const [],
                      referenceDate: DateTime.now(),
                      updateAppointDuration: (IntervalRange appointment,
                          IntervalRange newInterval) {
                        return Future.value(true);
                      },
                      optionalChildLine: (context, appointment, height) {
                    return Container();
                  },
                      appointmentBuilder: (BuildContext context,
                          IntervalRange appointment, double height) {
                        return Container();
                      },
                      key: key,
                    ),
                  ));

                  final currentState = key.currentState;
                  expect(currentState?.allowEdition, false);

            });

        testWidgets(
            'read only inactive',
                (WidgetTester tester) async {
              final DayScheduleListWidgetGlobalKey key = DayScheduleListWidgetGlobalKey();
              await tester.pumpWidget(MaterialApp(
                home: DayScheduleListWidget<IntervalRange>(
                  minimumMinuteInterval: MinuteInterval.fifteen,
                  appointmentMinimumDuration: MinuteInterval.fifteen,
                  hourHeight: 120,
                  unavailableIntervals: const [],
                  appointments: const [],
                  referenceDate: DateTime.now(),
                  createNewAppointmentAt: (intervalRange, error){},
                  updateAppointDuration: (IntervalRange appointment,
                      IntervalRange newInterval) {
                    return Future.value(true);
                  },
                  optionalChildLine: (context, appointment, height) {
                    return Container();
                  },
                  appointmentBuilder: (BuildContext context,
                      IntervalRange appointment, double height) {
                    return Container();
                  },
                  key: key,
                ),
              ));

              final currentState = key.currentState;
              expect(currentState?.allowEdition, true);

            });
      }
  );
}
