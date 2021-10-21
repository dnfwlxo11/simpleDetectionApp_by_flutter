import 'dart:io';

import 'package:flutter/material.dart';
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
      // theme: new ThemeData(scaffoldBackgroundColor: const Color(0xffe8e0fe)),
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
            child: Camera(),
          ),
          new Center(
            child: Gallery(),
          ),
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        // type: BottomNavigationBarType.fixed, // 메뉴가 3개 초과할때만 활성화
        backgroundColor: const Color(0xffe8e0fe),
        showUnselectedLabels: false,
        currentIndex: _bottomTabIndex,
        onTap: (int index) {
          setState(() => this._bottomTabIndex = index);
          this._pageController?.animateToPage(index,duration: const Duration(milliseconds: 500),curve: Curves.easeInOut);
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(icon: Icon(Icons.home, color: const Color(0xff5f6062)), title: Text('홈', style: TextStyle(color: const Color(0xff5f6062), fontWeight: FontWeight.bold))),
          new BottomNavigationBarItem(icon: Icon(Icons.camera, color: const Color(0xff5f6062)), title: Text('카메라', style: TextStyle(color: const Color(0xff5f6062), fontWeight: FontWeight.bold))),
          new BottomNavigationBarItem(icon: Icon(Icons.image, color: const Color(0xff5f6062)), title: Text('갤러리', style: TextStyle(color: const Color(0xff5f6062), fontWeight: FontWeight.bold))),
      ],)
    );
  }
}

