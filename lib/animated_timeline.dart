import 'package:flutter/material.dart';
import 'timeline.dart';

class AnimatedTimeLineChartController {
  DateTimeRange? targetRange;
  TimeLineChartController targetController;
  late final AnimationController animationController;
  final TickerProvider vsync;
  final Duration duration;
  final Curve curve;

  AnimatedTimeLineChartController({
    required this.vsync,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    required this.targetController,
  }) {
    animationController = AnimationController(
      vsync: vsync,
    );

    targetController.onTouch = stopAnimation;
  }

  stopAnimation() {
    animationController.stop();
  }

  Future<void> animateTo(DateTimeRange target,
      {Duration? duration, Curve? curve}) async {
    animationController.stop();

    targetRange = target;

    if (targetController.range == null) {
      targetController.range = targetRange;
      return;
    }

    if (targetController.range == targetRange) {
      return;
    }

    await animationController
        .animateTo(1,
            duration: duration ?? this.duration, curve: curve ?? this.curve)
        .then((value) {
      animationController.reset();
    });
  }
}

class AnimatedTimelineChart extends StatefulWidget {
  final AnimatedTimeLineChartController controller;

  const AnimatedTimelineChart({Key? key, required this.controller})
      : super(key: key);

  @override
  State<AnimatedTimelineChart> createState() => _AnimatedTimelineChartState();
}

class _AnimatedTimelineChartState extends State<AnimatedTimelineChart>
    with TickerProviderStateMixin {
  DateTime getStartDateByReference(double offset) {
    if (offset == 0) return widget.controller.targetController.range!.start;
    var startToTargetOffset = widget.controller.targetController.range!.start
            .difference(widget.controller.targetRange!.start) *
        offset;
    return widget.controller.targetController.range!.start
        .subtract(startToTargetOffset);
  }

  DateTime getEndDateByReference(double offset) {
    if (offset == 0) return widget.controller.targetController.range!.end;
    var endToTargetOffset = widget.controller.targetController.range!.end
            .difference(widget.controller.targetRange!.end) *
        offset;
    return widget.controller.targetController.range!.end
        .subtract(endToTargetOffset);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller.animationController,
      builder: (ctx, child) {
        widget.controller.targetController.range = DateTimeRange(
          start: getStartDateByReference(
              widget.controller.animationController.value),
          end: getEndDateByReference(
              widget.controller.animationController.value),
        );
        return TimelineChart(
          controller: widget.controller.targetController,
        );
      },
    );
  }
}
