class ScheduleItemPosition {
  ScheduleItemPosition({
    required this.top,
    required this.height,
  });
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
