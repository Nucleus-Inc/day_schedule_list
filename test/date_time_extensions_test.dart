import 'package:day_schedule_list/src/helpers/date_time_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  isSameDayTest();
}

void isSameDayTest() {
  group('.isSameDay()', () {
    test(
        'verify if 14/04/2009 is same day of 14/04/2009', () {
      expect(
        DateTime(2009, 4, 14).isSameDay(dateTime: DateTime(2009, 4, 14)),
        true
      );
    });
    test(
        'verify if 14/04/2008 is same day of 14/04/2009', () {
      expect(
          DateTime(2008, 4, 14).isSameDay(dateTime: DateTime(2009, 4, 14)),
          false
      );
    });
    test(
        'verify if 14/04/2009 14:00 is same day of 14/04/2009 23:59', () {
      expect(
          DateTime(2009, 4, 14, 14, 0).isSameDay(dateTime: DateTime(2009, 4, 14, 23, 59)),
          true
      );
    });
  });
}