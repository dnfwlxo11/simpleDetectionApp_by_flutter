import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CameraDetail extends StatefulWidget {
  final String imagePath;
  const CameraDetail({Key? key, required this.imagePath}) : super(key: key);

  @override
  _CameraDetailState createState() => _CameraDetailState();
}

class _CameraDetailState extends State<CameraDetail> {
  String url = 'http://192.168.0.106:16000/v2/models/detectionModel/versions/1/infer';
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

    var imageTmp = await decodeImageFromList(File(widget.imagePath).readAsBytesSync());
    String base64Image = base64Encode(await File(widget.imagePath).readAsBytesSync());

    var body = json.encode({
      "inputs": [
        {
          "name": "image_arrays:0",
          "shape": [1, imageTmp.height, imageTmp.width, 3],
          "datatype": "UINT8",
          "parameters": {
            "binary_data_size": base64Image.length
          }
        }
      ],

      "parameters":{
        "binary_data_output": false
      }
    });

    var response = await http.post(
        Uri.parse(url),
        headers: {
          'Inference-Header-Content-Length': '${body.length}',
          'Accept': '*/*'
        },
        body: (body + base64Image)
    );

    print('ok');

    // setState(() => isComplete = false);

    // var request = http.MultipartRequest('POST', Uri.parse(url));
    //
    // // 보낼 것 세팅
    // request.files.add(await http.MultipartFile.fromPath(
    //   'image',
    //   widget.imagePath
    // ));
    //
    // // String base64Image = base64Encode(await File(widget.imagePath).readAsBytesSync());
    //
    // // print(request.fields);
    //
    // var response = await request.send();

    var predict = json.decode(response.body)['outputs'][0]['data'];
    List<List> boxData = [];

    for (var i=0;i<((predict.length)/7).toInt();i++) {
      boxData.add(predict.sublist(0, 7));
    }

    for (var i in boxData) {
      print('좌표: ${i.sublist(1, 5)}');
      print('정확도: ${i[1]}');
      print('클래스 인덱스: ${i[2]}');
    }

    // setState(() => isComplete = true);
    // setState(() => isImage = true);
  }

  void saveAction() async {
    showToast('이미지 저장');

    setState(() => isImage = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('촬영한 이미지보기')),
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
