import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_detection_app/home.dart';
import 'package:simple_detection_app/gallery.dart';
import 'package:simple_detection_app/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // path provider to get the path of files
  // image picker wish is a cool plugin that allow us to pick image from difference source
  File? _image;
  int _bottomTabIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController(initialPage: _bottomTabIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    return Scaffold(
      appBar: AppBar(
        title: Text('디텍팅 앱'),
        backgroundColor: Colors.lightBlue,
      ),
      body: new PageView(
        controller: _pageController,
        onPageChanged: (newPage) {
          setState(() {
            this._bottomTabIndex = newPage;
          });
        },
        children: <Widget>[
          new Center(
            child: Home(),
          ),
          new Center(
            child: Camera(image: _image),
          ),
          new Center(
            child: Gallery(),
          ),
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _bottomTabIndex,
        onTap: (int index) {
          setState(() => this._bottomTabIndex = index);
          this._pageController?.animateToPage(index,duration: const Duration(milliseconds: 1000),curve: Curves.easeInOut);
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('홈'),),
          new BottomNavigationBarItem(icon: Icon(Icons.camera), title: Text('카메라'),),
          new BottomNavigationBarItem(icon: Icon(Icons.image), title: Text('갤러리'),)
      ],)
    );
  }
}

