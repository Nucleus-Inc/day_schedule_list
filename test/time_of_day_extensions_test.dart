import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:day_schedule_list/src/helpers/time_of_day_extensions.dart';

void main() {
  _toMinutesTest();
  _lessThanOperatorTests();
  _biggerThanOperatorTests();
  _lessThanOrEqualOperatorTests();
  _biggerThanOrEqualOperatorTests();
}

void _toMinutesTest() {
  test(
    '.toMinutes returns TimeOfDay value in minutes',
    () {
      const time = TimeOfDay(
        hour: 23,
        minute: 49,
      );
      expect(time.toMinutes, equals(23 * 60 + 49));
    },
  );
}

void _lessThanOperatorTests() {
  group('< operator tests', () {
    test(
      'TimeOfDay < other one after it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        const timeTwo = TimeOfDay(
          hour: 23,
          minute: 50,
        );
        expect(time < timeTwo, true);
      },
    );
    test(
      'TimeOfDay < other one equal it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        expect(time < time, false);
      },
    );
    test(
      'TimeOfDay < other one before it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        const timeTwo = TimeOfDay(
          hour: 3,
          minute: 50,
        );
        expect(time < timeTwo, false);
      },
    );
  });
}

void _biggerThanOperatorTests() {
  group('> operator tests', () {
    test(
      'TimeOfDay > other one after it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        const timeTwo = TimeOfDay(
          hour: 23,
          minute: 50,
        );
        expect(time > timeTwo, false);
      },
    );
    test(
      'TimeOfDay > other one equal it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        expect(time > time, false);
      },
    );
    test(
      'TimeOfDay > other one before it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        const timeTwo = TimeOfDay(
          hour: 3,
          minute: 50,
        );
        expect(time > timeTwo, true);
      },
    );
  });
}

void _lessThanOrEqualOperatorTests() {
  group('<= operator tests', () {
    test(
      'TimeOfDay <= other one after it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        const timeTwo = TimeOfDay(
          hour: 23,
          minute: 50,
        );
        expect(time <= timeTwo, true);
      },
    );
    test(
      'TimeOfDay <= other one equal it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        expect(time <= time, true);
      },
    );
    test(
      'TimeOfDay <= other one before it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        const timeTwo = TimeOfDay(
          hour: 3,
          minute: 50,
        );
        expect(time <= timeTwo, false);
      },
    );
  });
}

void _biggerThanOrEqualOperatorTests() {
  group('>= operator tests', () {
    test(
      'TimeOfDay >= other one after it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        const timeTwo = TimeOfDay(
          hour: 23,
          minute: 50,
        );
        expect(time >= timeTwo, false);
      },
    );
    test(
      'TimeOfDay >= other one equal it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        expect(time >= time, true);
      },
    );
    test(
      'TimeOfDay >= other one before it',
      () {
        const time = TimeOfDay(
          hour: 23,
          minute: 49,
        );
        const timeTwo = TimeOfDay(
          hour: 3,
          minute: 50,
        );
        expect(time >= timeTwo, true);
      },
    );
  });
}
