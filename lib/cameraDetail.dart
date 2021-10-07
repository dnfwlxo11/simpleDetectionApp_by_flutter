import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CameraDetail extends StatefulWidget {
  final String imagePath;
  const CameraDetail({Key? key, required this.imagePath}) : super(key: key);

  @override
  _CameraDetailState createState() => _CameraDetailState();
}

class _CameraDetailState extends State<CameraDetail> {
  bool isComplete = true;

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.lightBlue,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('촬영한 이미지보기')),
        // 이미지는 디바이스에 파일로 저장됩니다. 이미지를 보여주기 위해 주어진
        // 경로로 `Image.file`을 생성하세요.
        body: Stack(
          children: [
            Image.file(File(widget.imagePath)),
            isComplete ?
            Positioned(
              bottom: 40,
              right: 10,
              child: RaisedButton(
                color: Colors.lightBlue,
                onPressed: () {
                  showToast('디텍팅 시작');
                  isComplete = false;
                  var timer = Timer(Duration(seconds: 5), () => {
                    isComplete = true,
                  });
                  timer.cancel();
                },
                child: isComplete ? Text('디텍팅하기') : Text('저장하기'),
              ),
            ) : CircularProgressIndicator()
          ],
        )
    );
  }
}
