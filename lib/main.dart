import 'package:flutter/material.dart';

import 'TLC.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            range: DateTimeRange(
              start: DateTime(2020, 5, 10),
              end: DateTime(2020, 5, 13),
            ),
          ),
        ),
      ),
    );
  }
}

