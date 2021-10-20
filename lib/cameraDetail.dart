import 'dart:convert';
import 'dart:io';

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as crop;
import 'package:flutter/services.dart' show rootBundle;

class CameraDetail extends StatefulWidget {
  final String imagePath;
  const CameraDetail({Key? key, required this.imagePath}) : super(key: key);

  @override
  _CameraDetailState createState() => _CameraDetailState();
}

class _CameraDetailState extends State<CameraDetail> {
  bool isComplete = true;
  bool isDetect = false;
  File? _image;
  RenderBox? renderBox;
  double detectImgWidth = 0.0;
  double detectImgHeight = 0.0;
  var labelMap;

  List boxData = [];

  @override
  void initState() {
    super.initState();
    print(widget.imagePath);
    getLabelMap();
    setState(() { _image = File(widget.imagePath); });
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        renderBox = imageBox.currentContext!.findRenderObject() as RenderBox;
        detectImgWidth = renderBox!.size.width;
        detectImgHeight = renderBox!.size.height;
      });
    });
  }

  getLabelMap() async {
    var tmp = json.decode(await rootBundle.loadString('assets/labelMap.json'));
    setState(() => labelMap = tmp);
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

  List<Widget> generateRect(points) {
    return List.generate(points.length, (idx) {
      return new Positioned(
        left: (points[idx]['x']*detectImgWidth),
        top: (points[idx]['y']*detectImgHeight),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(7),
              child: Text(
                '${labelMap['${points[idx]['class']}']}',
                style: TextStyle(fontSize: 20),
              ),
              color: Colors.blue,
            ),
            Container(
              width: (points[idx]['w']*detectImgWidth),
              height: (points[idx]['h']*detectImgHeight),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void detectAction() async {
    setState(() => isComplete = false);
    setState(() => isDetect = false);

    String url = 'http://192.168.0.106:16000/v2/models/detectionModel/versions/1/infer';

    var bytes = _image!.readAsBytesSync().buffer.asUint8List();

    crop.Image? image = await crop.decodeImage(bytes);
    var decodeBytes = image!.getBytes(format: crop.Format.rgb);

    var body = jsonEncode({
      "inputs": [
        {
          "name": "image_arrays:0",
          "shape": [1, image.height, image.width, 3],
          "datatype": "UINT8",
          "data": decodeBytes
        }
      ],

      "parameters":{
        "binary_data_output": false
      }
    });

    var response = await http.post(
        Uri.parse(url),
        body: body
    );

    var predict = json.decode(response.body)['outputs'][0]['data'];
    setState(() => boxData = []);

    for (var i=0;i<((predict.length)/7).toInt();i++) {
      var predictArr = predict.sublist(0 + (i * 7), 7 + (i * 7));
      log(predictArr.toString());
      if (predictArr[5] < 0.3) break;
      setState(() {
        boxData.add({
          'class': predictArr[6].toInt(),
          'x': predictArr[2] / image.width,
          'y': predictArr[1] / image.height,
          'w': (predictArr[4] - predictArr[2]) / image.width,
          'h': (predictArr[3] - predictArr[1]) / image.height,
        });
      });
    }

    setState(() => isDetect = true);
    setState(() => isComplete = true);
  }

  void backwardPage() {
    Navigator.pop(context);
  }

  void saveAction() async {
    showToast('이미지 저장');
    setState(() => isDetect = false);
  }

  GlobalKey imageBox = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('촬영한 이미지보기')),
        body: Stack(
          children: [
            Container(
              key: imageBox,
              child: AspectRatio(
                aspectRatio: 3.0 / 4.0,
                child: Image.file(_image!, fit: BoxFit.fill),
              ),
            ),
            isComplete ?
            Positioned(
              bottom: 40,
              right: 10,
              child: Row(
                children: [
                  RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: backwardPage,
                      child: Text('다시찍기')
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  isDetect ? RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: detectAction,
                      child: Text('저장하기')
                  ) : RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: detectAction,
                      child: Text('디텍팅하기')
                  ),
                ],
              ),
            ) : CircularProgressIndicator(),
            if (renderBox != null) ...generateRect(boxData),
          ],
        )
    );
  }
}
