import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _containsTimeOfDayTests();
  _intersectsTests();
  _deltaIntervalInMinutesTests();
}

void _containsTimeOfDayTests() {
  group(
    '.containsTimeOfDay() verify that some TimeOfDay is inside of some '
        'IntervalRange',
        () {
      test(
        'start of IntervalRange belongs it',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDay(start), true);
        },
      );

      test(
        'end of IntervalRange belongs it',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDay(end), true);
        },
      );

      test(
        'Some TimeOfDay before IntervalRange.start is inside of IntervalRange',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          const timeOfDayBefore = TimeOfDay(hour: 9, minute: 59);
          expect(intervalRange.containsTimeOfDay(timeOfDayBefore), false);
        },
      );

      test(
        'Some TimeOfDay after IntervalRange.end is inside of IntervalRange',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          const timeOfDayAfter = TimeOfDay(hour: 12, minute: 40);
          expect(intervalRange.containsTimeOfDay(timeOfDayAfter), false);
        },
      );

      test(
        'Some TimeOfDay between IntervalRange.start and IntervalRange.end'
            ' is inside of IntervalRange',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          const timeOfDayBetween = TimeOfDay(hour: 11, minute: 59);
          expect(intervalRange.containsTimeOfDay(timeOfDayBetween), true);
        },
      );
    },
  );
}

void _intersectsTests() {
  group(
    '.itersects() verify some IntervalRange intersects another one.',
        () {
      test('IntervalRange intersects itself', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        expect(intervalRange.intersects(intervalRange), true);
      });
      test('IntervalRange intersects other because the other '
          'is contained on the one', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 11, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 0),
        );
        expect(intervalRange.intersects(intervalRangeTwo), true);
      },);
      test('IntervalRange intersects other because is contained on the other', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 0, minute: 0),
          end: const TimeOfDay(hour: 23, minute: 59),
        );
        expect(intervalRange.intersects(intervalRangeTwo), true);
      });
      test('IntervalRange intersects other by start', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 11, minute: 0),
          end: const TimeOfDay(hour: 16, minute: 0),
        );
        expect(intervalRange.intersects(intervalRangeTwo), true);
      });
      test('IntervalRange intersects other by end', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 11, minute: 47),
        );
        expect(intervalRange.intersects(intervalRangeTwo), true);
      });
      test('IntervalRange intersects other by end', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 11, minute: 47),
        );
        expect(intervalRange.intersects(intervalRangeTwo), true);
      });
      test('IntervalRange intersects other before it', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 9, minute: 47),
        );
        expect(intervalRange.intersects(intervalRangeTwo), false);
      });
      test('IntervalRange intersects other after it', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 13, minute: 0),
          end: const TimeOfDay(hour: 18, minute: 29),
        );
        expect(intervalRange.intersects(intervalRangeTwo), false);
      });
    },
  );
}

void _deltaIntervalInMinutesTests(){
  test('.deltaIntervalInMinutes returns interval in minutes on time interval',(){
    const start = TimeOfDay(hour: 10, minute: 0);
    const end = TimeOfDay(hour: 12, minute: 39);
    final intervalRange = IntervalRange(
      start: start,
      end: end,
    );
    expect(intervalRange.deltaIntervalIMinutes, equals(159));
  });
}
