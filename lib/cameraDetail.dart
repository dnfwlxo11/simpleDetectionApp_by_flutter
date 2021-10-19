import 'dart:convert';
import 'dart:io';

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
  String url = 'http://192.168.0.106:16000/v2/models/detectionModel/versions/1/infer';
  bool isComplete = true;
  bool isImage = false;
  File? _image;
  var labelMap;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLabelMap();
    print(labelMap);
    setState(() { _image = File(widget.imagePath); });

  }

  getLabelMap() async {
    return rootBundle.loadString('assets/labelMap.json')
    .then((jsonStr) => jsonDecode(jsonStr));
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

    print(response.body);

    var predict = json.decode(response.body)['outputs'][0]['data'];
    List<List> boxData = [];

    for (var i=0;i<((predict.length)/7).toInt();i++) {
      boxData.add(predict.sublist(0 + (i * 7), 7 + (i * 7)));
    }

    String result = '';
    for (var i in boxData) {
      if (i[5] < 0.3) break;
      result += '좌표: ${i.sublist(1, 5)} / 정확도: ${i[5]} / 클래스 인덱스: ${i[6]} \n';
    }

    showToast(result);
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
