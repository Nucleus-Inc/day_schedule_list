enum MinuteInterval { one, five, ten, fifteen, twenty, thirty }

extension NumberValue on MinuteInterval {
  int get numberValue {
    switch (this) {
      case MinuteInterval.one:
        return 1;
      case MinuteInterval.five:
        return 5;
      case MinuteInterval.ten:
        return 10;
      case MinuteInterval.fifteen:
        return 15;
      case MinuteInterval.twenty:
        return 20;
      case MinuteInterval.thirty:
        return 30;
    }
  }
}
