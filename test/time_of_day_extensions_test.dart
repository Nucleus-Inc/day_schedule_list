import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:day_schedule_list/src/helpers/time_of_day_extensions.dart';

void main() {
  _toMinutesTest();
  _lessThanOperatorTests();
  _biggerThanOperatorTests();
  _lessThanOrEqualOperatorTests();
  _biggerThanOrEqualOperatorTests();
  _addTests();
  _subtractTests();
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

void _addTests() {
  group('add method tests', (){
    test('increment 2 hour and 5 minutes',(){
      const time = TimeOfDay(
        hour: 10,
        minute: 0,
      );
      expect(time.add(hours: 2, minutes: 5), const TimeOfDay(
        hour: 12,
        minute: 5,
      ));
    });
    test('increment 0 hour and 5 minutes',(){
      const time = TimeOfDay(
        hour: 10,
        minute: 0,
      );
      expect(time.add(hours: 0, minutes: 5), const TimeOfDay(
        hour: 10,
        minute: 5,
      ));
    });
    test('increment 0 hour and 60 minutes',(){
      const time = TimeOfDay(
        hour: 10,
        minute: 0,
      );
      expect(time.add(hours: 0, minutes: 60), const TimeOfDay(
        hour: 11,
        minute: 0,
      ));
    });
    test('increment -2 hour and 0 minutes',(){
      const time = TimeOfDay(
        hour: 10,
        minute: 0,
      );
      expect(time.add(hours: -2, minutes: 0), const TimeOfDay(
        hour: 8,
        minute: 0,
      ));
    });
  });
}

void _subtractTests() {
  group('subtract method tests', (){
    test('decrement 2 hour and 5 minutes',(){
      const time = TimeOfDay(
        hour: 10,
        minute: 0,
      );
      expect(time.subtract(hours: 2, minutes: 5), const TimeOfDay(
        hour: 7,
        minute: 55,
      ));
    });
    test('decrement 0 hour and 5 minutes',(){
      const time = TimeOfDay(
        hour: 10,
        minute: 0,
      );
      expect(time.subtract(hours: 0, minutes: 5), const TimeOfDay(
        hour: 9,
        minute: 55,
      ));
    });
    test('decrement 0 hour and 60 minutes',(){
      const time = TimeOfDay(
        hour: 10,
        minute: 0,
      );
      expect(time.subtract(hours: 0, minutes: 60), const TimeOfDay(
        hour: 9,
        minute: 0,
      ));
    });
    test('decrement -2 hour and 0 minutes',(){
      const time = TimeOfDay(
        hour: 10,
        minute: 0,
      );
      expect(time.subtract(hours: -2, minutes: 0), const TimeOfDay(
        hour: 12,
        minute: 0,
      ));
    });
  });
}
