import 'package:flutter/material.dart';

class TimeLineChartController {
  DateTimeRange? range;
  final DateTime? initalTime;
  Function? onTouch;
  final double height;
  final Function(DateTime)? titleBuilder;
  final dynamic Function(DateTime)? onChange;
  final Duration minZoom;
  final Duration maxZoom;
  final Duration? initialZoom;
  final DateTime? minDateLimit;
  final DateTime? maxDateLimit;
  final List<DateTimeRange>? timeBlocks;
  final bool showCenteredTicker;
  final bool showUpperTickers;
  final bool showBottomTickers;
  final Color blockColor;
  final Color backgroundColor;
  final Color textBackgroundColor;
  final String Function(DateTime)? tickerTextBuilder;
  final TextStyle? tickerTextStyle;
  final double borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  late final Duration baseWindowSize;

  double scaleFactor = 1.0;
  double baseScaleFactor = 1.0;

  TimeLineChartController({
    this.range,
    this.initalTime,
    this.titleBuilder,
    this.height = 100,
    this.minZoom = const Duration(minutes: 5),
    this.maxZoom = const Duration(hours: 24),
    this.initialZoom,
    this.timeBlocks,
    this.onChange,
    this.backgroundColor = Colors.white,
    this.textBackgroundColor = Colors.red,
    this.showCenteredTicker = false,
    this.minDateLimit,
    this.maxDateLimit,
    this.blockColor = Colors.grey,
    this.showUpperTickers = true,
    this.borderRadius = 0,
    this.showBottomTickers = true,
    this.tickerTextBuilder,
    this.tickerTextStyle,
    this.border,
    this.boxShadow,
  }) {
    baseWindowSize = initialZoom ??
        Duration(
            milliseconds:
                ((minZoom + maxZoom).abs().inMilliseconds / 2).ceil());

    if (range == null) {
      var startDate = (initalTime ?? DateTime.now()).subtract(
          Duration(milliseconds: (baseWindowSize.inMilliseconds / 2).ceil()));

      var endDate = (initalTime ?? DateTime.now()).add(
          Duration(milliseconds: (baseWindowSize.inMilliseconds / 2).floor()));

      if (maxDateLimit != null && endDate.isAfter(maxDateLimit!)) {
        var durationShift = maxDateLimit!.difference(endDate);
        startDate = startDate.subtract(durationShift);
        endDate = endDate.subtract(durationShift);
      }

      if (minDateLimit != null && startDate.isBefore(minDateLimit!)) {
        var durationShift = minDateLimit!.difference(startDate);
        startDate = startDate.add(durationShift);
        endDate = endDate.add(durationShift);
      }

      range = DateTimeRange(
        start: startDate,
        end: endDate,
      );
    }
  }
}

class TimelineChart extends StatefulWidget {
  final TimeLineChartController controller;

  const TimelineChart({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<TimelineChart> createState() => _TimelineChartState();
}

class _TimelineChartState extends State<TimelineChart> {
  late TickerController hourController = TickerController(
    showText: true,
    getKey: (d) => d.hour,
    tickerTextBuilder: widget.controller.tickerTextBuilder,
    tickerTextStyle: widget.controller.tickerTextStyle,
  );

  late TickerController minutesController = TickerController(
    showText: true,
    stepDuration: const Duration(minutes: 1),
    getKey: (d) => d.minute,
    tickerTextBuilder: widget.controller.tickerTextBuilder,
    tickerTextStyle: widget.controller.tickerTextStyle,
  );

  late TickerController secondsController = TickerController(
    showText: true,
    stepDuration: const Duration(seconds: 1),
    getKey: (d) => d.second,
    showSeconds: true,
    tickerTextBuilder: widget.controller.tickerTextBuilder,
    tickerTextStyle: widget.controller.tickerTextStyle,
  );

  late TickerController midnightController = TickerController(
    getKey: (DateTime d) {
      return (d.minute == 0 && d.hour == 0) ? 1 : 0;
    },
    tickerTextBuilder: (dt) => '${dt.day}/${dt.month}',
    tickerTextStyle: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
    showText: true,
  );

  DateTime getCurrentTime() {
    Duration d = widget.controller.range!.end
        .difference(widget.controller.range!.start)
        .abs();
    DateTime newT = widget.controller.range!.start
        .add(Duration(milliseconds: (d.inMilliseconds / 2).floor()));
    if (widget.controller.onChange != null) {
      widget.controller.onChange!(newT);
    }
    return newT;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    shiftWindow(Duration shift) {
      DateTime newStart = widget.controller.range!.start.subtract(shift);

      if (widget.controller.minDateLimit != null &&
          newStart.isBefore(widget.controller.minDateLimit!)) {
        return;
      }

      DateTime newEnd = widget.controller.range!.end.subtract(shift);
      if (widget.controller.maxDateLimit != null &&
          newEnd.isAfter(widget.controller.maxDateLimit!)) {
        return;
      }
      var newRange = DateTimeRange(
        start: newStart,
        end: newEnd,
      );

      setState(() {
        widget.controller.range = newRange;
      });
    }

    scaleWindow(double scaleDelta) {
      int winSize =
          (widget.controller.baseWindowSize.inMilliseconds / scaleDelta)
              .floor();

      DateTime newStart = widget.controller.range!.start.subtract(Duration(
          milliseconds:
              ((winSize - widget.controller.range!.duration.inMilliseconds) / 2)
                  .floor()));

      if (widget.controller.minDateLimit != null &&
          newStart.isBefore(widget.controller.minDateLimit!)) {
        newStart = widget.controller.minDateLimit!;
      }

      DateTime newEnd = widget.controller.range!.end.add(Duration(
          milliseconds:
              ((winSize - widget.controller.range!.duration.inMilliseconds) / 2)
                  .floor()));

      if (widget.controller.maxDateLimit != null &&
          newEnd.isAfter(widget.controller.maxDateLimit!)) {
        newEnd = widget.controller.maxDateLimit!;
      }

      var newRange = DateTimeRange(
        start: newStart,
        end: newEnd,
      );

      if (newRange.duration >= const Duration(hours: 8)) {
        secondsController.showText = false;
        minutesController.showText = false;
        hourController.showText = true;
      } else if (newRange.duration >= const Duration(minutes: 5)) {
        secondsController.showText = false;
        minutesController.showText = true;
        hourController.showText = true;
      } else {
        secondsController.showText = true;
        minutesController.showText = true;
        hourController.showText = true;
      }

      setState(() {
        widget.controller.range = newRange;
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.controller.titleBuilder != null
            ? widget.controller.titleBuilder!(getCurrentTime())
            : Container(),
        GestureDetector(
          onTapDown: (_) => widget.controller.onTouch?.call(),
          onScaleStart: (details) {
            widget.controller.baseScaleFactor = widget.controller.scaleFactor;
          },
          onScaleUpdate: (details) {
            if (details.scale != 1 &&
                (!(details.scale < 1 &&
                        widget.controller.range!.duration >=
                            widget.controller.maxZoom) &&
                    !(details.scale > 1 &&
                        widget.controller.range!.duration <=
                            widget.controller.minZoom))) {
              widget.controller.scaleFactor =
                  widget.controller.baseScaleFactor * details.scale;
              scaleWindow(widget.controller.scaleFactor);
            }
          },
          onHorizontalDragUpdate: (details) {
            widget.controller.onTouch?.call();
            double shiftRatio = details.delta.dx / screenSize.width;
            Duration shift = Duration(
                milliseconds:
                    (widget.controller.range!.duration.inMilliseconds *
                            shiftRatio)
                        .floor());
            shiftWindow(shift);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: widget.controller.textBackgroundColor,
              border: widget.controller.border,
              borderRadius: BorderRadius.all(
                Radius.circular(widget.controller.borderRadius + 1),
              ),
              boxShadow: widget.controller.boxShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                  Radius.circular(widget.controller.borderRadius)),
              child: Stack(
                children: [
                  widget.controller.showCenteredTicker
                      ? Container(
                          alignment: Alignment.center,
                          child: Container(
                            color: Colors.red,
                            width: 2,
                          ),
                        )
                      : Container(),
                  Container(
                    height: widget.controller.height,
                    width: screenSize.width,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: widget.controller.backgroundColor,
                    ),
                  ),
                  SizedBox(
                    height: widget.controller.height,
                    width: screenSize.width,
                    child: CustomPaint(
                      painter: TimeBlockPaint(
                        timeBlocks: widget.controller.timeBlocks ?? [],
                        range: widget.controller.range!,
                        color: widget.controller.blockColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: widget.controller.height,
                    width: screenSize.width,
                    child: CustomPaint(
                      painter: Tickers(
                        range: widget.controller.range!,
                        upperTickers: widget.controller.showUpperTickers,
                        bottomTickers: widget.controller.showBottomTickers,
                        height: 20,
                        width: 1.5,
                        controller: hourController,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: widget.controller.height,
                    width: screenSize.width,
                    child: CustomPaint(
                      painter: Tickers(
                        range: widget.controller.range!,
                        upperTickers: widget.controller.showUpperTickers,
                        bottomTickers: widget.controller.showBottomTickers,
                        height: 10,
                        width: 1,
                        controller: minutesController,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: widget.controller.height,
                    width: screenSize.width,
                    child: CustomPaint(
                      painter: Tickers(
                        range: widget.controller.range!,
                        upperTickers: widget.controller.showUpperTickers,
                        bottomTickers: widget.controller.showBottomTickers,
                        height: 5,
                        width: 0.7,
                        controller: secondsController,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: widget.controller.height,
                    width: screenSize.width,
                    child: CustomPaint(
                      painter: Tickers(
                        range: widget.controller.range!,
                        upperTickers: widget.controller.showUpperTickers,
                        bottomTickers: widget.controller.showBottomTickers,
                        height: 25,
                        width: 2.5,
                        controller: midnightController,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: widget.controller.height,
                    width: screenSize.width,
                    child: CustomPaint(
                      painter: Tickers(
                        range: widget.controller.range!,
                        upperTickers: widget.controller.showUpperTickers,
                        bottomTickers: widget.controller.showBottomTickers,
                        height: 25,
                        width: 2.5,
                        controller: midnightController,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TickerController {
  bool showText;
  bool enable;
  Duration stepDuration;
  bool showSeconds;
  double tickerTextWidth;

  final int Function(DateTime) getKey;
  final String Function(DateTime)? tickerTextBuilder;
  final TextStyle? tickerTextStyle;

  TickerController({
    required this.getKey,
    this.tickerTextBuilder,
    this.showSeconds = false,
    this.showText = false,
    this.enable = true,
    this.tickerTextWidth = 70,
    this.stepDuration = const Duration(hours: 1),
    this.tickerTextStyle,
  });
}

class Tickers extends CustomPainter {
  final DateTimeRange range;
  final double height;
  final double width;
  final bool upperTickers;
  final bool bottomTickers;
  final TickerController? controller;
  final Color color;

  late final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = color;

  final TextPainter _textPaint = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.rtl,
  );

  Tickers({
    this.color = Colors.black,
    this.height = 15,
    this.width = 1.5,
    this.upperTickers = true,
    this.bottomTickers = true,
    this.controller,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!(controller?.enable ?? true)) {
      return;
    }

    Duration duration = controller?.stepDuration ?? const Duration(hours: 1);

    double step = size.width / range.duration.inMilliseconds;

    double realStep = step * (duration.inMilliseconds);

    if (realStep <= (width * 2)) {
      return;
    }

    Duration offsetDuration = Duration(
      minutes: range.start.minute,
      seconds: range.start.second,
      milliseconds: range.start.millisecond,
    );

    double offsetStart =
        (duration.inMilliseconds - offsetDuration.inMilliseconds) /
            duration.inMilliseconds;

    DateTime currentTime = range.start.subtract(Duration(
      milliseconds: range.start.millisecond,
      seconds: range.start.second,
      minutes: range.start.minute,
    ));

    for (double distance = offsetStart * realStep;
        distance < size.width;
        distance += realStep) {
      currentTime = currentTime.add(duration);

      int key = controller?.getKey(currentTime) ?? 0;
      if (key == 0) continue;

      String label = controller?.tickerTextBuilder?.call(currentTime) ??
          (toTwoDigitString(currentTime.hour) +
              ":" +
              toTwoDigitString(currentTime.minute));

      if (controller?.showSeconds ?? false) {
        label += ":" + toTwoDigitString(currentTime.second);
      }

      _textPaint.text = TextSpan(
        style: controller?.tickerTextStyle ?? const TextStyle(),
        text: label,
      );

      _textPaint.layout(
        maxWidth: controller?.tickerTextWidth ?? 50,
        minWidth: controller?.tickerTextWidth ?? 50,
      );

      int textMod = 1;
      bool needPaintText = false;

      textMod = ((controller?.tickerTextWidth ?? 50) / realStep).ceil();
      if (textMod == 1) {
        textMod = 1;
      } else if (textMod >= 20) {
        textMod = 30;
      } else if (textMod >= 15) {
        textMod = 20;
      } else if (textMod >= 5) {
        textMod = 10;
      } else {
        textMod = 5;
      }

      if (key % textMod == 0) {
        needPaintText = true;
      }

      if (needPaintText && (controller?.showText ?? true)) {
        _textPaint.paint(
          canvas,
          Offset(
            distance - (_textPaint.width / 2),
            (size.height - _textPaint.height) + 20,
          ),
        );
      }

      if (bottomTickers && ((realStep >= width * 3) || needPaintText)) {
        canvas.drawLine(
          Offset(distance, size.height),
          Offset(distance, size.height - height),
          _paint,
        );
      }

      if (upperTickers && ((realStep >= width * 3) || needPaintText)) {
        canvas.drawLine(
          Offset(distance, 0),
          Offset(distance, height),
          _paint,
        );
      }
    }
  }

  toTwoDigitString(int num) {
    if (num < 10) return '0' + num.toString();
    return num.toString();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    DateTimeRange oldRange = (oldDelegate as Tickers).range;
    return oldRange.start != range.start || oldRange.end != range.end;
  }
}

class TimeBlockPaint extends CustomPainter {
  final List<DateTimeRange> timeBlocks;
  final Color color;
  final DateTimeRange range;

  late final Paint _paint = Paint()..color = color;

  TimeBlockPaint({
    required this.timeBlocks,
    required this.range,
    this.color = Colors.blue,
  });

  buildBlockByScreenSize(Canvas canvas, Size size, double start, double end) {
    canvas.drawRect(
      Rect.fromPoints(Offset(start, 0), Offset(end, size.height)),
      _paint,
    );
  }

  buildBlockByRange(
      Canvas canvas, Size size, double msWidth, DateTimeRange blockRange) {
    DateTime start = blockRange.start;
    DateTime end = blockRange.end;

    if (end.isBefore(range.start) || start.isAfter(range.end)) return;

    int startComp = start.compareTo(range.start);
    int endComp = end.compareTo(range.end);

    if (startComp < 0) start = range.start;

    if (endComp > 0) end = range.end;

    double blockSize = (end.difference(start)).inMilliseconds * msWidth;

    double blockOffset =
        (start.difference(range.start)).inMilliseconds * msWidth;

    if (blockSize >= 0 && blockOffset >= 0) {
      buildBlockByScreenSize(
          canvas, size, blockOffset, blockOffset + blockSize);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    double msWidth = size.width / range.duration.inMilliseconds;
    for (DateTimeRange block in timeBlocks) {
      buildBlockByRange(canvas, size, msWidth, block);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    DateTimeRange oldRange = (oldDelegate as TimeBlockPaint).range;
    return oldRange.start != range.start || oldRange.end != range.end;
  }
}
