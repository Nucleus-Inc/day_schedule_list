extension DateTimeExtensions on DateTime {
  bool isSameDay({required DateTime dateTime}) {
    return year == dateTime.year &&
        month == dateTime.month &&
        day == dateTime.day;
  }
}
