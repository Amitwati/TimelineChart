import 'package:flutter/material.dart';
import 'TLC.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final TimelineChartController controller =
      TimelineChartController(value: DateTime(2020, 5, 10, 12, 12));

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Center(
          child: TimelineChart(
            controller: widget.controller,
            height: 75,
            busy: [
              [
                DateTime(2020, 11, 8, 18, 50),
                DateTime(2020, 11, 8, 18, 55),
              ],
              [
                DateTime(2020, 11, 8, 12, 50),
                DateTime(2020, 11, 8, 18, 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
