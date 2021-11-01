import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_detection_app/bottomPage/main/mainPage.dart';
import 'package:simple_detection_app/bottomPage/gallery/galleryPage.dart';
import 'package:simple_detection_app/bottomPage/camera/cameraPage.dart';

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
        body: PageView(
          controller: _pageController,
          onPageChanged: (newPage) {
            setState(() {
              this._bottomTabIndex = newPage;
            });
          },
          children: <Widget>[
            new Center(
              child: MainPage(),
            ),
            new Center(
              child: CameraPage(),
            ),
            new Center(
              child: GalleryPage(),
            ),
          ],
        ),
        bottomNavigationBar: new BottomNavigationBar(
          // type: BottomNavigationBarType.fixed, // 메뉴가 3개 초과할때만 활성화
          backgroundColor: Color(0xff5293c9),
          showUnselectedLabels: false,
          currentIndex: _bottomTabIndex,
          onTap: (int index) {
            setState(() => this._bottomTabIndex = index);
            this._pageController?.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
          },
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(icon: Icon(Icons.home, color: Color(0xffeeeeee)), title: Text('홈', style: TextStyle(color: Color(0xffeeeeee), fontWeight: FontWeight.bold))),
            new BottomNavigationBarItem(icon: Icon(Icons.camera, color: Color(0xffeeeeee)), title: Text('카메라', style: TextStyle(color: Color(0xffeeeeee), fontWeight: FontWeight.bold))),
            new BottomNavigationBarItem(icon: Icon(Icons.image, color: Color(0xffeeeeee)), title: Text('갤러리', style: TextStyle(color: Color(0xffeeeeee), fontWeight: FontWeight.bold))),
          ])
    );
  }
}

