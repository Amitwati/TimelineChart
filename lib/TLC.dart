import 'package:flutter/material.dart';

class TimelineChartController {
  DateTime value;

  TimelineChartController({this.value}) {
    if (this.value == null) {
      this.value = DateTime.now();
    }
  }
}

class TimelineChart extends StatefulWidget {
  final double height;
  final Widget Function(DateTime) titleBuilder;
  final Duration minZoom;
  final Duration maxZoom;
  final List<List<DateTime>> busy;
  final TimelineChartController controller;
  final double secondsTickerHeight;
  final double minutesTickerHeight;
  final double hoursTickerHeight;

  TimelineChart({
    Key key,
    @required this.controller,
    this.titleBuilder,
    this.height = 100,
    this.minZoom = const Duration(seconds: 4),
    this.maxZoom = const Duration(hours: 12),
    this.busy,
    this.secondsTickerHeight = 10,
    this.minutesTickerHeight = 20,
    this.hoursTickerHeight = 30,
  }) : super(key: key);

  @override
  _TimelineChartState createState() => _TimelineChartState();
}

class _TimelineChartState extends State<TimelineChart> {
  Size screenSize;
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  Duration windowSize;
  DateTimeRange winRange;
  Duration _baseWindowSize;

  @override
  void initState() {
    super.initState();
    _baseWindowSize = Duration(hours: 2);
    this.windowSize = _baseWindowSize;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    winRange = DateTimeRange(
      start: widget.controller.value.subtract(
          Duration(milliseconds: (windowSize.inMilliseconds / 2).ceil())),
      end: widget.controller.value
          .add(Duration(milliseconds: (windowSize.inMilliseconds / 2).floor())),
    );

    shiftWindow(Duration shift) {
      setState(() {
        widget.controller.value = widget.controller.value.subtract(shift);
      });
    }

    scaleWindow(double scaleDelta) {
      int winSize = (_baseWindowSize.inMilliseconds / scaleDelta).floor();

      DateTime newStart = winRange.start.subtract(Duration(
          milliseconds: ((winSize - windowSize.inMilliseconds) / 2).floor()));

      DateTime newEnd = winRange.end.add(Duration(
          milliseconds: ((winSize - windowSize.inMilliseconds) / 2).floor()));

      setState(() {
        winRange = DateTimeRange(
          start: newStart,
          end: newEnd,
        );
        this.windowSize = winRange.start.difference(winRange.end).abs();
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.titleBuilder != null
            ? widget.titleBuilder(widget.controller.value)
            : Text(widget.controller.value.toString()),
        GestureDetector(
          onScaleStart: (details) {
            _baseScaleFactor = _scaleFactor;
          },
          onScaleUpdate: (details) {
            if (details.scale != 1 &&
                (!(details.scale < 1 && windowSize >= widget.maxZoom) &&
                    !(details.scale > 1 && windowSize <= widget.minZoom)))
              setState(() {
                _scaleFactor = _baseScaleFactor * details.scale;
                scaleWindow(_scaleFactor);
              });
          },
          onHorizontalDragUpdate: (details) {
            double shiftRatio = details.delta.dx / screenSize.width;

            Duration shift = Duration(
                milliseconds:
                    (this.windowSize.inMilliseconds * shiftRatio).floor());
            setState(() {
              shiftWindow(shift);
            });
          },
          child: Container(
            // color: Colors.white,
            height: widget.height,
            width: screenSize.width,
            decoration: BoxDecoration(
              boxShadow: [
                const BoxShadow(
                  color: Colors.black12,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(2, 2),
                  spreadRadius: -2.0,
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  height: widget.height,
                  width: screenSize.width,
                  child: CustomPaint(
                    painter: Tickers(
                      range: this.winRange,
                      secondsTickerHeight: widget.secondsTickerHeight,
                      minutesTickerHeight: widget.minutesTickerHeight,
                      hoursTickerHeight: widget.hoursTickerHeight,
                      busy: widget.busy,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Tickers extends CustomPainter {
  final DateTimeRange range;
  final double secondsTickerHeight;
  final double minutesTickerHeight;
  final double hoursTickerHeight;

  int _secMod;
  int _minMod;
  int _hourMod;
  Duration _duration;
  List<List<DateTime>> busy;

  final TextPainter textPaint = new TextPainter(
    textAlign: TextAlign.left,
    textDirection: TextDirection.rtl,
  );

  Paint _secondsPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = Colors.black;

  Paint _minutesPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.red;

  Paint _hoursPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.black;

  Paint _rectPaint = Paint()..color = Colors.blue[200];

  Tickers({
    this.range,
    this.secondsTickerHeight,
    this.minutesTickerHeight,
    this.hoursTickerHeight,
    this.busy,
  }) {
    _secMod = 1;
    _minMod = 1;
    _hourMod = 1;
    _duration = range.end.difference(range.start).abs();
    if (_duration.inHours > 10) {
      _secMod = 60;
      _minMod = 60;
      _hourMod = 5;
    } else if (_duration.inHours > 5) {
      _secMod = 60;
      _minMod = 60;
      _hourMod = 2;
    } else if (_duration.inHours > 1) {
      _secMod = 60;
      _minMod = 30;
      _hourMod = 1;
    } else if (_duration.inMinutes > 45) {
      _secMod = 60;
      _minMod = 15;
    } else if (_duration.inMinutes > 30) {
      _secMod = 60;
      _minMod = 5;
    } else if (_duration.inMinutes > 10) {
      _secMod = 60;
      _minMod = 5;
    } else if (_duration.inMinutes > 5) {
      _secMod = 60;
      _minMod = 2;
    } else if (_duration.inMinutes > 1) {
      _secMod = 30;
      _minMod = 1;
    } else if (_duration.inSeconds > 45) {
      _secMod = 10;
    } else if (_duration.inSeconds > 30) {
      _secMod = 5;
    } else if (_duration.inSeconds > 15) {
      _secMod = 5;
    } else if (_duration.inSeconds > 5) {
      _secMod = 2;
    }
  }

  paintRect(Canvas canvas, Size size, double start, double end) {
    canvas.drawRect(Rect.fromPoints(Offset(start, size.height), Offset(end, 0)),
        _rectPaint);
  }

  paintBusy(Canvas canvas, Size size, DateTime start, DateTime end) {
    if (end.isBefore(range.start) || start.isAfter(range.end)) {
      return;
    }

    if (start.isBefore(range.start)) {
      start = range.start;
    }

    if (end.isAfter(range.end)) {
      end = range.end;
    }

    double rectOffset = (range.start.difference(start).abs().inMilliseconds /
        this._duration.inMilliseconds);
    rectOffset *= size.width;

    double rectEnd = (range.start.difference(end).abs().inMilliseconds /
        this._duration.inMilliseconds);
    rectEnd *= size.width;

    paintRect(canvas, size, rectOffset, rectEnd);
  }

  @override
  void paint(Canvas canvas, Size size) {
    double offsetStart;
    double realStep;
    Duration stepDuration;
    double step = size.width / (_duration.inMilliseconds / 1000);

    for (List<DateTime> b in (this.busy ?? [])) {
      paintBusy(canvas, size, b[0], b[1]);
    }

    if (_secMod != 60) {
      realStep = step;
      stepDuration = Duration(seconds: 1);
      offsetStart = this.range.start.millisecond == 0
          ? 0
          : (1000 - this.range.start.millisecond) / 1000;
    } else {
      // no need for deconds
      if (_minMod == 60) {
        // no need for minutes and
        stepDuration = Duration(hours: 1);
        realStep = step * 3600;
        offsetStart = this.range.start.minute == 0
            ? 0
            : (60 - this.range.start.minute) / 60;
      } else {
        realStep = step * 60;
        stepDuration = Duration(minutes: 1);
        offsetStart = this.range.start.second == 0
            ? 0
            : (60 - this.range.start.second) / 60;
      }
    }

    DateTime t = range.start;
    t = t.subtract(Duration(milliseconds: t.millisecond));
    offsetStart = offsetStart == 0 ? 1 : offsetStart;

    for (double i = offsetStart * realStep; i < size.width; i += realStep) {
      t = t.add(stepDuration);
      if (_secMod == 60 && t.second != 0) {
        t = t.subtract(Duration(seconds: t.second));
      }
      if (_minMod == 60 && t.minute != 0) {
        t = t.subtract(Duration(seconds: t.second));
        t = t.subtract(Duration(minutes: t.minute));
      }
      String label =
          toTwoDigitString(t.hour) + ":" + toTwoDigitString(t.minute);

      if (t.second == 0) {
        if (t.minute == 0) {
          // build hour ticker
          if (t.hour % _hourMod == 0) {
            buildHourTicker(
              canvas,
              i,
              size,
              label,
            );
          }
        } else {
          //build minute ticker
          {
            if (t.minute % _minMod == 0) {
              buildMinuteTicker(
                canvas,
                i,
                size,
                label,
              );
            }
          }
        }
      } else {
        // build second ticker
        if (t.second % _secMod == 0) {
          buildSecondTicker(
            canvas,
            i,
            size,
            label + ":" + toTwoDigitString(t.second),
          );
        }
      }
    }
  }

  buildHourTicker(
    Canvas canvas,
    double distance,
    Size size,
    String label,
  ) {
    textPaint.text = TextSpan(
      style: new TextStyle(color: Colors.blue[800], fontSize: 15),
      text: label,
    );
    textPaint.layout();

    textPaint.paint(
      canvas,
      new Offset(
        distance - (textPaint.width / 2),
        size.height - this.hoursTickerHeight - (textPaint.width / 2),
      ),
    );
    canvas.drawLine(
      Offset(distance, size.height),
      Offset(distance, size.height - this.hoursTickerHeight),
      _hoursPaint,
    );
  }

  buildMinuteTicker(
    Canvas canvas,
    double distance,
    Size size,
    String label,
  ) {
    textPaint.text = TextSpan(
      style: new TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
      text: label,
    );
    textPaint.layout();
    textPaint.paint(
      canvas,
      new Offset(
        distance - (textPaint.width / 2),
        size.height - this.minutesTickerHeight - (textPaint.width / 2),
      ),
    );
    canvas.drawLine(
      Offset(distance, size.height),
      Offset(distance, size.height - this.minutesTickerHeight),
      _minutesPaint,
    );
  }

  buildSecondTicker(
    Canvas canvas,
    double distance,
    Size size,
    String label,
  ) {
    textPaint.text = TextSpan(
      style: TextStyle(
        color: Colors.grey,
        fontSize: 10,
      ),
      text: label,
    );
    textPaint.layout();
    textPaint.paint(
      canvas,
      new Offset(
        distance - (textPaint.width / 2),
        size.height - this.secondsTickerHeight - (textPaint.width / 2),
      ),
    );
    canvas.drawLine(
      Offset(distance, size.height),
      Offset(distance, size.height - this.secondsTickerHeight),
      _secondsPaint,
    );
  }

  toTwoDigitString(int num) {
    if (num < 10) return '0' + num.toString();
    return num.toString();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    DateTimeRange oldRange = (oldDelegate as Tickers).range;
    return oldRange.start != this.range.start || oldRange.end != this.range.end;
  }
}
