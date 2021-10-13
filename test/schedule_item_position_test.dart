import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _scheduleItemPositionInitTest();
}

void _scheduleItemPositionInitTest() {
  test('ScheduleItemPosition initializer assertion height > 0', () {
    expect(() => ScheduleItemPosition(top: 10, height: 0), throwsAssertionError);
  });
  test('ScheduleItemPosition initializer assertion top >= 0', () {
    expect(() => ScheduleItemPosition(top: -10, height: 120), throwsAssertionError);
  });
}
