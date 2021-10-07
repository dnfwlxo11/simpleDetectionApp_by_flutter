import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class CameraDetail extends StatefulWidget {
  final String imagePath;
  const CameraDetail({Key? key, required this.imagePath}) : super(key: key);

  @override
  _CameraDetailState createState() => _CameraDetailState();
}

class _CameraDetailState extends State<CameraDetail> {
  String url = 'http://192.168.0.106:3000/flutter';
  bool isComplete = true;
  bool isImage = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.lightBlue,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM
    );
  }

  void detectAction() async {
    showToast('디텍팅 시작');
    setState(() => isComplete = false);

    var request = http.MultipartRequest('POST', Uri.parse(url));

    // 헤더 세팅
    // request.headers["Content-Type"] = "multipart/json";

    // 보낼 것 세팅
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      widget.imagePath
    ));
    var response = await request.send();

    print(response.contentLength);

    setState(() => isComplete = true);
    setState(() => isImage = true);
  }

  void saveAction() async {
    showToast('이미지 저장');

    setState(() => isImage = false);
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
                  onPressed: isImage ? saveAction : detectAction,
                  child: isImage ? Text('저장하기') : Text('디텍팅하기'),
                ),
              ) : CircularProgressIndicator()
          ],
        )
    );
  }
}
