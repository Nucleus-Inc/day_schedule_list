class ScheduleItemPosition {
  ScheduleItemPosition({
    required this.top,
    required this.height,
  })  : assert(height > 0, 'height must be > 0'),
        assert(top >= 0, 'top must be >= 0');
  final double top;
  final double height;

  ScheduleItemPosition withNewTop(double top) {
    return ScheduleItemPosition(
      top: top,
      height: height,
    );
  }

  ScheduleItemPosition withNewHeight(double height) {
    return ScheduleItemPosition(
      top: top,
      height: height,
    );
  }
}
