import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  // path provider to get the path of files
  // image picker wish is a cool plugin that allow us to pick image from difference source
  File? _image;
  final imagePicker = ImagePicker();
  int bottomTabIndex = 0;

  // 카메라에서 이미지 가져오기
  Future getImage() async {
    final image = await imagePicker.getImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 480, imageQuality: 100); // 해당 라인이 카메라에서 이미지를 가져올 수 있게 해줌
    setState(() {
      _image = File(image!.path);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Text("사진을 먼저 촬영해야합니다.") : Image.file(_image!),
            _image == null ? Text('') : RaisedButton(
              color: Colors.lightBlue,
              onPressed: getImage,
              child: Text('다시 촬영', style: TextStyle(color: Colors.white)),
            )
          ],
        )
      ),
    );
  }
}
