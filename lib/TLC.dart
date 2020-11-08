import 'package:flutter/material.dart';

class TimelineChart extends StatefulWidget {
  final DateTimeRange range;
  final double height;
  final Widget Function(DateTime) titleBuilder;

  TimelineChart({
    Key key,
    @required this.range,
    this.titleBuilder,
    this.height = 100,
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
    _baseWindowSize = widget.range.start.difference(widget.range.end).abs();
    this.windowSize = _baseWindowSize;
    winRange = DateTimeRange(
      start: widget.range.start,
      end: widget.range.start.add(windowSize),
    );
  }

  DateTime getCurrentTime() {
    Duration d = winRange.end.difference(winRange.start).abs();
    DateTime newT = winRange.start
        .add(Duration(milliseconds: (d.inMilliseconds / 2).floor()));
    return newT;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    shiftWindow(Duration shift) {
      setState(() {
        winRange = DateTimeRange(
          start: winRange.start.subtract(shift),
          end: winRange.end.subtract(shift),
        );
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
            ? widget.titleBuilder(getCurrentTime())
            : Text(getCurrentTime().toString()),
        GestureDetector(
          onScaleStart: (details) {
            _baseScaleFactor = _scaleFactor;
          },
          onScaleUpdate: (details) {
            if (details.scale != 1 &&
                (!(details.scale < 1 && windowSize.inHours >= 12) &&
                    !(details.scale > 1 && windowSize.inSeconds <= 4)))
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
            color: Colors.white,
            height: widget.height,
            width: screenSize.width,
            child: Stack(
              children: [
                Container(
                  height: widget.height,
                  width: screenSize.width,
                  child: CustomPaint(
                    painter: Tickers(
                      range: this.winRange,
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
  int _secMod;
  int _minMod;
  int _hourMod;
  Duration _duration;

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

  Tickers({
    this.range,
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
        size.height - 25 - (textPaint.width / 2),
      ),
    );
    canvas.drawLine(
      Offset(distance, size.height),
      Offset(distance, size.height - 30),
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
        size.height - 20 - (textPaint.width / 2),
      ),
    );
    canvas.drawLine(
      Offset(distance, size.height),
      Offset(distance, size.height - 20),
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
        size.height - 5 - (textPaint.width / 2),
      ),
    );
    canvas.drawLine(
      Offset(distance, size.height),
      Offset(distance, size.height - 10),
      _secondsPaint,
    );
  }

  toTwoDigitString(int num) {
    if (num < 10) return '0' + num.toString();
    return num.toString();
  }

  @override
  void paint(Canvas canvas, Size size) {
    double step = size.width / (_duration.inMilliseconds / 1000);

    double offsetStart;
    double realStep = step;
    Duration stepDuration = Duration(seconds: 1);

    if (_secMod != 60) {
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

    if (_secMod == 60 && t.second != 0) {
      t = t.add(Duration(seconds: 60 - t.second));
    }
    if (_minMod == 60 && t.minute != 0) {
      t = t.add(Duration(minutes: 60 - t.minute));
    }

    offsetStart = offsetStart == 0 ? 1 : offsetStart;
    for (double i = offsetStart * realStep; i < size.width; i += realStep) {
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
      t = t.add(stepDuration);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    DateTimeRange oldRange = (oldDelegate as Tickers).range;
    return oldRange.start != this.range.start || oldRange.end != this.range.end;
  }
}
