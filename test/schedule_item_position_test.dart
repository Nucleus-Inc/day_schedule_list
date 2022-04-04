import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _scheduleItemPositionInitTest();
  _scheduleItemPositionWithNewHeight();
  _scheduleItemPositionWithNewTop();
  _scheduleItemPositionFromPosition();
}

void _scheduleItemPositionInitTest() {
  test('ScheduleItemPosition initializer assertion height > 0', () {
    expect(() => ScheduleItemPosition(top: 10, height: 0), throwsAssertionError);
  });
  test('ScheduleItemPosition initializer assertion top >= 0', () {
    expect(() => ScheduleItemPosition(top: -10, height: 120), throwsAssertionError);
  });
}

void _scheduleItemPositionWithNewHeight(){
  test('ScheduleItemPosition.withNewHeight', () {
    final position = ScheduleItemPosition(top: 10, height: 10);
    final newPosition = position.withNewHeight(120);
    expect(newPosition.height, 120);
    expect(newPosition.top, position.top);
  });
}

void _scheduleItemPositionWithNewTop(){
  test('ScheduleItemPosition.withNewTop', () {
    final position = ScheduleItemPosition(top: 10, height: 10);
    final newPosition = position.withNewTop(120);
    expect(newPosition.top, 120);
    expect(newPosition.height, position.height);
  });
}

void _scheduleItemPositionFromPosition(){
  test('ScheduleItemPosition.fromPosition', () {
    final position = ScheduleItemPosition(top: 10, height: 10);
    final newPosition = ScheduleItemPosition.fromPosition(position);
    expect(newPosition.top, position.top);
    expect(newPosition.height, position.height);
  });
}
