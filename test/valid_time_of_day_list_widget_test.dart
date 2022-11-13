import 'package:day_schedule_list/src/models/interval_range.dart';
import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_inherited.dart';
import 'package:day_schedule_list/src/ui/day_schedule_list_widget_mixin.dart';
import 'package:day_schedule_list/src/ui/time_of_day_widget.dart';
import 'package:day_schedule_list/src/ui/valid_time_of_day_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _unavailableIntervals = [
  IntervalRange(
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 8, minute: 30)),
  IntervalRange(
      start: const TimeOfDay(hour: 12, minute: 0),
      end: const TimeOfDay(hour: 13, minute: 15)),
  IntervalRange(
      start: const TimeOfDay(hour: 18, minute: 30),
      end: const TimeOfDay(hour: 22, minute: 30))
];

void main() {
  _timeOfDayWidgetListTest();
}

void _timeOfDayWidgetListTest() {
  group('TimeOfDayWidget items config', () {
    testWidgets(
        'items count when having valid intervals without unavailable intervals',
        (WidgetTester tester) async {
      final List<ScheduleTimeOfDay> validIntervals = [];

      for (var index = 0; index < 25; index++) {
        validIntervals.add(
          ScheduleTimeOfDay.available(
            time: TimeOfDay(hour: index, minute: 0),
          ),
        );
      }

      await tester.pumpWidget(MaterialApp(
        home: DayScheduleListInherited(
          minimumMinuteInterval: MinuteInterval.fifteen,
          minimumMinuteIntervalHeight: 35,
          customDragIndicator: null,
          timeOfDayWidgetHeight: 35 * 4,
          dragIndicatorColor: null,
          validTimesList: validIntervals,
          timeOfDayColor: null,
          dragIndicatorBorderWidth: null,
          dragIndicatorBorderColor: null,
          child: const SingleChildScrollView(
            child: ValidTimeOfDayListWidget(),
          ),
        ),
      ));

      final columnFinder = find.byWidgetPredicate((widget) => widget is Column);
      expect(columnFinder, isNotNull);

      final List<Widget> columnChildren = (columnFinder.evaluate().first.widget as Column).children;
      expect(columnChildren, isNotNull);
      expect(columnChildren.whereType<TimeOfDayWidget>().length, 25);
      expect(columnChildren.whereType<SizedBox>().length, 26);
    });

    testWidgets(
        'items count when having valid intervals with unavailable intervals',
        (WidgetTester tester) async {
      final List<ScheduleTimeOfDay> validIntervals =
          _DayScheduleListWidgetMethodsTest().populateValidTimesList(
        unavailableIntervals: _unavailableIntervals,
      );

      await tester.pumpWidget(MaterialApp(
        home: DayScheduleListInherited(
          minimumMinuteInterval: MinuteInterval.fifteen,
          minimumMinuteIntervalHeight: 35,
          customDragIndicator: null,
          timeOfDayWidgetHeight: 35 * 4,
          dragIndicatorColor: null,
          validTimesList: validIntervals,
          timeOfDayColor: null,
          dragIndicatorBorderWidth: null,
          dragIndicatorBorderColor: null,
          child: const SingleChildScrollView(
            child: ValidTimeOfDayListWidget(),
          ),
        ),
      ));

      final columnFinder = find.byWidgetPredicate((widget) => widget is Column);
      expect(columnFinder, isNotNull);

      final List<Widget> columnChildren = (columnFinder.evaluate().first.widget as Column).children;

      expect(columnChildren.whereType<TimeOfDayWidget>().length, 11);
      expect(columnChildren.whereType<SizedBox>().length, 12);
    });
  });
}

class _DayScheduleListWidgetMethodsTest with DayScheduleListWidgetMixin {
  _DayScheduleListWidgetMethodsTest();
  @override
  double get hourHeight => 100;
}
