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
            initalTime: DateTime.now(),
            onChange: (t) {
              print("time picked : $t");
            },
            titleBuilder: (t) {
              return Container(
                width: 200,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.yellow[200],
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(2, 2),
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 1),
                    ]),
                child: Text(
                  t.hour.toString() +
                      ":" +
                      t.minute.toString() +
                      ":" +
                      t.second.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
