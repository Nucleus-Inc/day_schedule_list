import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/helpers/time_of_day_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _initializerAssertTest();
  _containsTimeOfDayTests();
  _containsTimeOfDayPartialClosedTests();
  _intersectsTests();
  _equalOperatorTests();
  _deltaIntervalInMinutesTests();
  _hashCodeTests();
}

void _initializerAssertTest() {
  group(
    'Verify initializer assert',
        () {
      test(
        'start > end',
            () {
          const end = TimeOfDay(hour: 10, minute: 0);
          const start = TimeOfDay(hour: 12, minute: 39);

          expect((){
            IntervalRange(
              start: start,
              end: end,
            );
          }, throwsA(isAssertionError));
        },
      );
      test(
        'start == end',
            () {
          const start = TimeOfDay(hour: 12, minute: 39);
          expect((){
            IntervalRange(
              start: start,
              end: start,
            );
          }, throwsA(isAssertionError));
        },
      );
      test(
        'start < end',
            () {
          const start = TimeOfDay(hour: 12, minute: 39);
          const end = TimeOfDay(hour: 13, minute: 39);
          expect(IntervalRange(
            start: start,
            end: end,
          ), isInstanceOf<IntervalRange>());
        },
      );
    },
  );
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
          expect(intervalRange.containsTimeOfDay(start, closedRange: true), true);
          expect(intervalRange.containsTimeOfDay(start, closedRange: false), false);
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
          expect(intervalRange.containsTimeOfDay(end, closedRange: true), true);
          expect(intervalRange.containsTimeOfDay(end, closedRange: false), false);
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
          expect(intervalRange.containsTimeOfDay(timeOfDayBefore, closedRange: true), false);
          expect(intervalRange.containsTimeOfDay(timeOfDayBefore, closedRange: false), false);
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
          expect(intervalRange.containsTimeOfDay(timeOfDayAfter, closedRange: true), false);
          expect(intervalRange.containsTimeOfDay(timeOfDayAfter, closedRange: false), false);
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
          expect(intervalRange.containsTimeOfDay(timeOfDayBetween, closedRange: true), true);
          expect(intervalRange.containsTimeOfDay(timeOfDayBetween, closedRange: false), true);
          },
      );
    },
  );
}

void _containsTimeOfDayPartialClosedTests() {
  group(
    '.containsTimeOfDayPartialClosed() verify that some TimeOfDay is inside of some '
        'IntervalRange',
        () {
      test(
        'start of IntervalRange belongs it full closed range',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: start,
            closedRangeOnStart: true,
            closedRangeOnEnd: true,
          ), true);
        },
      );

      test(
        'start of IntervalRange belongs it full unclosed range',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: start,
            closedRangeOnStart: false,
            closedRangeOnEnd: false,
          ), false);
        },
      );

      test(
        'start of IntervalRange belongs it closed range on start',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: start,
            closedRangeOnStart: true,
            closedRangeOnEnd: false,
          ), true);
        },
      );

      test(
        'start of IntervalRange belongs it closed range on end',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: start,
            closedRangeOnStart: false,
            closedRangeOnEnd: true,
          ), false);
        },
      );

      test(
        'end of IntervalRange belongs it full closed range',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: end,
            closedRangeOnStart: true,
            closedRangeOnEnd: true,
          ), true);
        },
      );

      test(
        'end of IntervalRange belongs it full unclosed range',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: end,
            closedRangeOnStart: false,
            closedRangeOnEnd: false,
          ), false);
        },
      );

      test(
        'end of IntervalRange belongs it closed range on start',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: end,
            closedRangeOnStart: true,
            closedRangeOnEnd: false,
          ), false);
        },
      );

      test(
        'end of IntervalRange belongs it closed range on end',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: end,
            closedRangeOnStart: false,
            closedRangeOnEnd: true,
          ), true);
        },
      );

      test(
        'Some TimeOfDay before IntervalRange.start is inside of IntervalRange full closed range',
            () {
              const start = TimeOfDay(hour: 10, minute: 0);
              const end = TimeOfDay(hour: 12, minute: 39);
              final intervalRange = IntervalRange(
                start: start,
                end: end,
              );
              const timeOfDayBefore = TimeOfDay(hour: 9, minute: 59);
              expect(intervalRange.containsTimeOfDayPartialClosed(
                time: timeOfDayBefore,
                closedRangeOnStart: true,
                closedRangeOnEnd: true,
              ), false);
            },
      );

      test(
        'Some TimeOfDay before IntervalRange.start is inside of IntervalRange full unclosed range',
            () {
              const start = TimeOfDay(hour: 10, minute: 0);
              const end = TimeOfDay(hour: 12, minute: 39);
              final intervalRange = IntervalRange(
                start: start,
                end: end,
              );
              const timeOfDayBefore = TimeOfDay(hour: 9, minute: 59);
              expect(intervalRange.containsTimeOfDayPartialClosed(
                time: timeOfDayBefore,
                closedRangeOnStart: false,
                closedRangeOnEnd: false,
              ), false);
        },
      );

      test(
        'Some TimeOfDay after IntervalRange.end is inside of IntervalRange full closed range',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          const timeOfDayAfter = TimeOfDay(hour: 12, minute: 40);
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: timeOfDayAfter,
            closedRangeOnStart: true,
            closedRangeOnEnd: true,
          ), false);
        },
      );

      test(
        'Some TimeOfDay after IntervalRange.end is inside of IntervalRange full unclosed range',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          const timeOfDayAfter = TimeOfDay(hour: 12, minute: 40);
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: timeOfDayAfter,
            closedRangeOnStart: false,
            closedRangeOnEnd: false,
          ), false);
        },
      );

      test(
        'Some TimeOfDay between IntervalRange.start and IntervalRange.end is inside of IntervalRange full closed range',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          const timeOfDayBetween = TimeOfDay(hour: 11, minute: 59);
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: timeOfDayBetween,
            closedRangeOnStart: true,
            closedRangeOnEnd: true,
          ), true);
        },
      );

      test(
        'Some TimeOfDay between IntervalRange.start and IntervalRange.end is inside of IntervalRange full unclosed range',
            () {
          const start = TimeOfDay(hour: 10, minute: 0);
          const end = TimeOfDay(hour: 12, minute: 39);
          final intervalRange = IntervalRange(
            start: start,
            end: end,
          );
          const timeOfDayBetween = TimeOfDay(hour: 11, minute: 59);
          expect(intervalRange.containsTimeOfDayPartialClosed(
            time: timeOfDayBetween,
            closedRangeOnStart: false,
            closedRangeOnEnd: false,
          ), true);
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
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: true), true);
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: false), true);
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
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: true), true);
        expect(intervalRange.intersects(intervalRangeTwo,closedRange: false), true);
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
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: true), true);
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: false), true);
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
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: true), true);
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: false), true);
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
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: true), true);
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: false), true);
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
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: true), false);
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: false), false);
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
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: true), false);
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: false), false);
      });
      test('IntervalRange intersects other equal to it', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );

        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );

        expect(intervalRange.intersects(intervalRangeTwo, closedRange: true), true);
        expect(intervalRange.intersects(intervalRangeTwo, closedRange: false), true);
      });
    },
  );
}

void _equalOperatorTests(){
  group(
    '== operator verify some IntervalRange is equal another.',
        () {
      test('IntervalRange equals to itself', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        expect(intervalRange == intervalRange, true);
      });
      test('IntervalRange equals to other instance with same start and end values'
          'is contained on the one', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        expect(intervalRange == intervalRangeTwo, true);
        expect(intervalRangeTwo == intervalRange, true);
      },);
      test('IntervalRange equals to other with different start', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 0, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        expect(intervalRange == intervalRangeTwo, false);
        expect(intervalRangeTwo == intervalRange, false);
      });
      test('IntervalRange equals to other with different end', () {
        final intervalRange = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 39),
        );
        final intervalRangeTwo = IntervalRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 16, minute: 0),
        );
        expect(intervalRange == intervalRangeTwo, false);
        expect(intervalRangeTwo == intervalRange, false);
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

void _hashCodeTests(){
  test('.hashCode is equals to start.toMinutes + end.toMinutes',(){
    const start = TimeOfDay(hour: 10, minute: 0);
    const end = TimeOfDay(hour: 12, minute: 39);
    final intervalRange = IntervalRange(
      start: start,
      end: end,
    );
    expect(intervalRange.hashCode, equals(start.toMinutes + end.toMinutes));
  });
}

