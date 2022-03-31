import 'package:day_schedule_list/day_schedule_list.dart';
import 'package:day_schedule_list/src/models/schedule_item_position.dart';
import 'package:day_schedule_list/src/models/schedule_time_of_day.dart';
import 'package:flutter/cupertino.dart';

class DayScheduleListInherited extends InheritedWidget {
  const DayScheduleListInherited({
    required Widget child,
    required this.scrollController,
    required this.mediaQueryData,
    required this.validTimesList,
    required this.minimumMinuteIntervalHeight,
    required this.timeOfDayWidgetHeight,
    required this.minimumMinuteInterval,
    required this.dragIndicatorColor,
    required this.dragIndicatorBorderWidth,
    required this.dragIndicatorBorderColor,
    required this.customDragIndicator,
    this.allowEdition = false,
    Key? key,
  }) : super(
          child: child,
          key: key,
        );

  final List<ScheduleTimeOfDay> validTimesList;
  final double minimumMinuteIntervalHeight;
  final double timeOfDayWidgetHeight;
  final MinuteInterval minimumMinuteInterval;

  final Color? dragIndicatorColor;
  final Color? dragIndicatorBorderColor;
  final double? dragIndicatorBorderWidth;
  final CustomDragIndicatorBuilder? customDragIndicator;

  final bool allowEdition;
  final MediaQueryData mediaQueryData;
  final ScrollController scrollController;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  bool newSchedulePositionIsOnMaxVisibleTop(
    ScheduleItemPosition newPosition,
    ScheduleItemPosition oldPosition,
  ) {
    final offsetIncrement = newPosition.top - oldPosition.top;
    final currentScrollOffset = scrollController.offset;
    return newPosition.top - currentScrollOffset <= 50 && offsetIncrement < 0;
  }

  bool newSchedulePositionIsOnMaxVisibleBottom(
    ScheduleItemPosition newPosition,
    ScheduleItemPosition oldPosition,
  ) {
    final windowSize = mediaQueryData.size;
    final offsetIncrement = newPosition.top - oldPosition.top;
    final currentScrollOffset = scrollController.offset;
    print(windowSize.height -
        (newPosition.top + newPosition.height - currentScrollOffset));
    return windowSize.height -
                (newPosition.top + newPosition.height - currentScrollOffset) <=
            130 &&
        offsetIncrement > 0;
  }

  static DayScheduleListInherited of(BuildContext context) {
    final DayScheduleListInherited? result =
        context.dependOnInheritedWidgetOfExactType<DayScheduleListInherited>();
    assert(result != null, 'No DayScheduleListInherited found in context');
    return result!;
  }
}
