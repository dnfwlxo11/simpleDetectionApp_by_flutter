import 'package:flutter/material.dart';
import 'package:simple_detection_app/mainPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detect!',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Simple Detection App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String text = 'Hi';
  bool isOk = true;
  var idx = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      isOk ? text = 'Hi' : text = 'Hello';
      isOk = !isOk;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.title),
        ),
        body: mainPage(),

        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              idx = index;
            });
          },
          currentIndex: idx,
          items: <BottomNavigationBarItem> [
            BottomNavigationBarItem(
              title: Text('홈'),
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              title: Text('갤러리'),
              icon: Icon(Icons.assignment),
            ),
          ],
        ),


        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
    );
  }
}
