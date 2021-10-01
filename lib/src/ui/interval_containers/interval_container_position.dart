import 'package:flutter/material.dart';
import '../../models/schedule_item_position.dart';

class IntervalContainerPosition extends StatelessWidget {
  const IntervalContainerPosition({
    required this.position,
    required this.child,
    Key? key,
  }) : super(key: key);

  final ScheduleItemPosition position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.top,
      right: 0,
      left: 40,
      child: child,
    );
  }
}
