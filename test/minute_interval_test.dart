import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _numberValueTests();
}

void _numberValueTests() {
  test('.numberValue returns correct minute value', () {
    final List<int> numberValues = MinuteInterval.values
        .map((e) => e.numberValue)
        .toList()
      ..sort((a, b) => a.compareTo(b));
    final possibleValues = [
      1,5,10,15,20,30,
    ];
    expect(numberValues, equals(possibleValues));
  });
}
