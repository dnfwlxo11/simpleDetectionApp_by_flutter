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
  final imagePicker = ImagePicker();
  int bottomTabIndex = 0;

  // 카메라에서 이미지 가져오기
  Future getImage() async {
    final image = await imagePicker.getImage(source: ImageSource.camera); // 해당 라인이 카메라에서 이미지를 가져올 수 있게 해줌
    setState(() {
      _image = File(image!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    final List<Widget> _children = [Home(), Camera(), Gallery()];

    switch (bottomTabIndex) {
      case 0:
        child = Text('test1');
        break;
      case 1:
        child = Text('test2');
        break;
      case 2:
        child = Text('test3');
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('디텍팅 앱'),
        backgroundColor: Colors.lightBlue,
      ),
      body: _children[bottomTabIndex],
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: bottomTabIndex,
        onTap: (int index) { setState(() => this.bottomTabIndex = index); },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('홈'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            title: Text('카메라'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.image),
            title: Text('갤러리'),
          )
      ],)
    );
  }
}

