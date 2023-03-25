import 'package:TimelineChart/timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'animated_timeline.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimatedTimeLineChartController controller;

  @override
  void initState() {
    this.controller = AnimatedTimeLineChartController(
        vsync: this,
        targetController: TimeLineChartController(
          range: DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 1)),
            end: DateTime.now(),
          ),
        ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTimelineChart(
              controller: controller,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await controller.animateTo(
            DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 2)),
              end: DateTime.now().subtract(const Duration(days: 1)),
            ),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
