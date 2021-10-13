import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as UI show Image;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';


class DetectDetail extends StatefulWidget {
  final imgData;

  const DetectDetail({Key? key, required this.imgData}) : super(key: key);

  @override
  _DetectDetailState createState() => _DetectDetailState();
}

class _DetectDetailState extends State<DetectDetail> {
  UI.Image? _image;
  bool isImageloaded = false;


  var detectSample = {
    'x': 10,
    'y': 10,
    'w': 100,
    'h': 100,
  };

  void setData() {
    print(widget.imgData is File);
  }

  void loadUiImage() async {
    // final ByteData data = await widget.imgData.readAsBytes().buffer.asByteData();
    // final ByteData data = await rootBundle.load(imageAssetPath);
    print('hi');
    // print(await decodeImageFromList(widget.imgData.readAsBytes()));
    _image = await decodeImageFromList(Uint8List.fromList(File(widget.imgData.path).readAsBytesSync()));
    print('hello');

  }

  @override
  void initState() {
    // TODO: implement initState
    loadUiImage();
    setData();
    print(_image);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(title: Text('자세히 보기')),
      body: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child:
              Container(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 3.0 / 4.0,
                  child: Image.file(widget.imgData, fit: BoxFit.fill),
                ),
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 3.0 / 4.0,
                  child: Text('${DateFormat('yyyy년 MM월 dd일 hh시 mm분 ').format(widget.imgData.statSync().accessed)}'),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: CustomPaint(
                size: Size(10, 10),
                painter: MyPainter(detectSample, _image),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  var detect;
  UI.Image? image;

  MyPainter(detect, image) {
    this.detect = detect;
    this.image = image;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = Colors.deepPurpleAccent // 색은 보라색
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..strokeWidth = 4.0; // 선의 굵기는 4.0

    canvas.drawRect(Rect.fromLTWH(detect['x'].toDouble(), detect['y'].toDouble(), detect['w'].toDouble(), detect['h'].toDouble()), paint);
    // canvas.drawImage(image, new Offset(50.0, 50.0), paint);
    // canvas.drawRect(Rect.fromLTWH(10, 10, 100, 100), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}