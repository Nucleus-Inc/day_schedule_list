import 'package:day_schedule_list/src/models/minute_interval.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _numberValueTests();
  _operatorsTests();
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

void _operatorsTests(){
  group('MinuteInterval operators tests', (){
    test('MinuteInterval.fifteen > MinuteInterval.one', (){
      expect(MinuteInterval.fifteen > MinuteInterval.one, true);
    });
    test('MinuteInterval.fifteen > MinuteInterval.five', (){
      expect(MinuteInterval.fifteen > MinuteInterval.five, true);
    });
    test('MinuteInterval.fifteen > MinuteInterval.ten', (){
      expect(MinuteInterval.fifteen > MinuteInterval.ten, true);
    });
    test('MinuteInterval.fifteen > MinuteInterval.fifteen', (){
      expect(MinuteInterval.fifteen > MinuteInterval.fifteen, false);
    });
    test('MinuteInterval.fifteen > MinuteInterval.twenty', (){
      expect(MinuteInterval.fifteen > MinuteInterval.twenty, false);
    });
    test('MinuteInterval.fifteen > MinuteInterval.thirty', (){
      expect(MinuteInterval.fifteen > MinuteInterval.thirty, false);
    });

    test('MinuteInterval.fifteen >= MinuteInterval.one', (){
      expect(MinuteInterval.fifteen >= MinuteInterval.one, true);
    });
    test('MinuteInterval.fifteen >= MinuteInterval.five', (){
      expect(MinuteInterval.fifteen >= MinuteInterval.five, true);
    });
    test('MinuteInterval.fifteen >= MinuteInterval.ten', (){
      expect(MinuteInterval.fifteen >= MinuteInterval.ten, true);
    });
    test('MinuteInterval.fifteen >= MinuteInterval.fifteen', (){
      expect(MinuteInterval.fifteen >= MinuteInterval.fifteen, true);
    });
    test('MinuteInterval.fifteen >= MinuteInterval.twenty', (){
      expect(MinuteInterval.fifteen >= MinuteInterval.twenty, false);
    });
    test('MinuteInterval.fifteen >= MinuteInterval.thirty', (){
      expect(MinuteInterval.fifteen >= MinuteInterval.thirty, false);
    });

    test('MinuteInterval.fifteen < MinuteInterval.one', (){
      expect(MinuteInterval.fifteen < MinuteInterval.one, false);
    });
    test('MinuteInterval.fifteen < MinuteInterval.five', (){
      expect(MinuteInterval.fifteen < MinuteInterval.five, false);
    });
    test('MinuteInterval.fifteen < MinuteInterval.ten', (){
      expect(MinuteInterval.fifteen < MinuteInterval.ten, false);
    });
    test('MinuteInterval.fifteen < MinuteInterval.fifteen', (){
      expect(MinuteInterval.fifteen < MinuteInterval.fifteen, false);
    });
    test('MinuteInterval.fifteen < MinuteInterval.twenty', (){
      expect(MinuteInterval.fifteen < MinuteInterval.twenty, true);
    });
    test('MinuteInterval.fifteen < MinuteInterval.thirty', (){
      expect(MinuteInterval.fifteen < MinuteInterval.thirty, true);
    });

    test('MinuteInterval.fifteen <= MinuteInterval.one', (){
      expect(MinuteInterval.fifteen <= MinuteInterval.one, false);
    });
    test('MinuteInterval.fifteen <= MinuteInterval.five', (){
      expect(MinuteInterval.fifteen <= MinuteInterval.five, false);
    });
    test('MinuteInterval.fifteen <= MinuteInterval.ten', (){
      expect(MinuteInterval.fifteen <= MinuteInterval.ten, false);
    });
    test('MinuteInterval.fifteen <= MinuteInterval.fifteen', (){
      expect(MinuteInterval.fifteen <= MinuteInterval.fifteen, true);
    });
    test('MinuteInterval.fifteen <= MinuteInterval.twenty', (){
      expect(MinuteInterval.fifteen <= MinuteInterval.twenty, true);
    });
    test('MinuteInterval.fifteen <= MinuteInterval.thirty', (){
      expect(MinuteInterval.fifteen <= MinuteInterval.thirty, true);
    });
  });
}
