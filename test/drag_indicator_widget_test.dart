import 'package:day_schedule_list/src/ui/interval_containers/appointment_container/drag_indicator_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _modeTopTest();
  _modeBottomTest();
  _modeOverlayTopTest();
  _modeOverlayBottomTest();
  _whenEnabledOrDisabled();
}

void _modeTopTest() {
  testWidgets('DragIndicatorWidget.top', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Stack(
        children: [
          DragIndicatorWidget.top(
            enabled: true,
            onLongPressDown: () {},
            onLongPressStart: (start) {},
            onLongPressEnd: (end) {},
            onLongPressMoveUpdate: (update) {},
          )
        ],
      ),
    ));

    final positionedFinder = find
        .byWidgetPredicate((widget) => widget is Positioned);

    expect(positionedFinder, isNotNull);

    final Positioned positioned = positionedFinder
        .evaluate()
        .first
        .widget as Positioned;

    expect(positioned.top, lessThan(0));
    expect(positioned.bottom, isNull);
    expect(positioned.right, isNull);
    expect(positioned.left, isZero);

    expect(find.byWidgetPredicate((widget) => widget is AnimatedOpacity), isNotNull);
  });
}

void _modeBottomTest() {
  testWidgets('DragIndicatorWidget.bottom', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Stack(
        children: [
          DragIndicatorWidget.bottom(
            enabled: true,
            onLongPressDown: () {},
            onLongPressStart: (start) {},
            onLongPressEnd: (end) {},
            onLongPressMoveUpdate: (update) {},
          )
        ],
      ),
    ));

    final positionedFinder = find
        .byWidgetPredicate((widget) => widget is Positioned);

    expect(positionedFinder, isNotNull);

    final Positioned positioned = positionedFinder
        .evaluate()
        .first
        .widget as Positioned;

    expect(positioned.top, lessThan(0));
    expect(positioned.bottom, isNull);
    expect(positioned.right, isNull);
    expect(positioned.left, isZero);

    expect(find.byWidgetPredicate((widget) => widget is AnimatedOpacity), isNotNull);
  });
}

void _modeOverlayTopTest() {
  testWidgets('DragIndicatorWidget.overlayTop', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Stack(
        children: const [
          DragIndicatorWidget.overlayTop()
        ],
      ),
    ));

    final positionedFinder = find
        .byWidgetPredicate((widget) => widget is Positioned);

    expect(positionedFinder, isNotNull);

    final Positioned positioned = positionedFinder
        .evaluate()
        .first
        .widget as Positioned;

    expect(positioned.top, lessThan(0));
    expect(positioned.bottom, isNull);
    expect(positioned.right, isNull);
    expect(positioned.left, isZero);

    expect(find.byWidgetPredicate((widget) => widget is AnimatedOpacity), isNotNull);
  });
}

void _modeOverlayBottomTest() {
  testWidgets('DragIndicatorWidget.overlayBottom', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Stack(
        children: const [
          DragIndicatorWidget.overlayBottom()
        ],
      ),
    ));

    final positionedFinder = find
        .byWidgetPredicate((widget) => widget is Positioned);

    expect(positionedFinder, isNotNull);

    final Positioned positioned = positionedFinder
        .evaluate()
        .first
        .widget as Positioned;

    expect(positioned.top, lessThan(0));
    expect(positioned.bottom, isNull);
    expect(positioned.right, isNull);
    expect(positioned.left, isZero);

    expect(find.byWidgetPredicate((widget) => widget is AnimatedOpacity), isNotNull);
  });
}


void _whenEnabledOrDisabled(){
  group('When enabled or disabled',(){
    testWidgets('enabled = true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Stack(
          children: [
            DragIndicatorWidget.top(
              enabled: true,
              onLongPressDown: () {},
              onLongPressStart: (start) {},
              onLongPressEnd: (end) {},
              onLongPressMoveUpdate: (update) {},
            )
          ],
        ),
      ));

      final finder = find
          .byWidgetPredicate((widget) => widget is AnimatedOpacity);

      expect(finder, isNotNull);

      final AnimatedOpacity animatedOpacity = finder
          .evaluate()
          .first
          .widget as AnimatedOpacity;

      expect(animatedOpacity.opacity, 1);

      final gestureDetectorFinder = find
          .byWidgetPredicate((widget) => widget is GestureDetector);
      expect(gestureDetectorFinder, isNotNull);
      final GestureDetector gestureDetector = gestureDetectorFinder
          .evaluate()
          .first
          .widget as GestureDetector;
      expect(gestureDetector.onLongPress, isNotNull);
      expect(gestureDetector.onLongPressStart, isNotNull);
      expect(gestureDetector.onLongPressEnd, isNotNull);
      expect(gestureDetector.onLongPressMoveUpdate, isNotNull);
    });


    testWidgets('enabled = false', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Stack(
          children: [
            DragIndicatorWidget.top(
              enabled: false,
              onLongPressDown: () {},
              onLongPressStart: (start) {},
              onLongPressEnd: (end) {},
              onLongPressMoveUpdate: (update) {},
            )
          ],
        ),
      ));

      final finder = find
          .byWidgetPredicate((widget) => widget is AnimatedOpacity);

      expect(finder, isNotNull);

      final AnimatedOpacity animatedOpacity = finder
          .evaluate()
          .first
          .widget as AnimatedOpacity;

      expect(animatedOpacity.opacity, 0);

      final gestureDetectorFinder = find
          .byWidgetPredicate((widget) => widget is GestureDetector);
      expect(gestureDetectorFinder, isNotNull);
      final GestureDetector gestureDetector = gestureDetectorFinder
          .evaluate()
          .first
          .widget as GestureDetector;
      expect(gestureDetector.onLongPress, isNull);
      expect(gestureDetector.onLongPressStart, isNull);
      expect(gestureDetector.onLongPressEnd, isNull);
      expect(gestureDetector.onLongPressMoveUpdate, isNull);
    });
  });
}
