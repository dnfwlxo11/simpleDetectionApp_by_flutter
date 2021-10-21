import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as crop;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CameraDetail extends StatefulWidget {
  final String imagePath;
  const CameraDetail({Key? key, required this.imagePath}) : super(key: key);

  @override
  _CameraDetailState createState() => _CameraDetailState();
}

class _CameraDetailState extends State<CameraDetail> {
  var conn;

  bool isComplete = true;
  bool isDetect = false;
  File? _image;
  List uint8Image = [];
  RenderBox? renderBox;
  double detectImgWidth = 0.0;
  double detectImgHeight = 0.0;
  var labelMap;

  List boxData = [];

  void initDb() async {
    var mysqlSetting = new ConnectionSettings(
        host: 'namuintell.iptime.org',
        port: 16003,
        user: 'root',
        password: 'root',
        db: 'detections'
    );

    setState(() async => conn = await MySqlConnection.connect(mysqlSetting));
  }

  @override
  void initState() {
    super.initState();
    initDb();
    getLabelMap();
    print(widget.imagePath);
    setState(() {
      _image = File(widget.imagePath);
    });
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        renderBox = imageBox.currentContext!.findRenderObject() as RenderBox;
        detectImgWidth = renderBox!.size.width;
        detectImgHeight = renderBox!.size.height;
      });
    });
  }

  void getLabelMap() async {
    var tmp = json.decode(await rootBundle.loadString('assets/labelMap.json'));
    setState(() => labelMap = tmp);
  }

  @override
  void dispose() {
    _image!.deleteSync();
    super.dispose();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: const Color(0xffe8e0fe),
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
                style: TextStyle(fontSize: 20, color: const Color(0xff5f6062)),
              ),
              color: const Color(0xffe8e0fe),
            ),
            Container(
              width: (points[idx]['w']*detectImgWidth),
              height: (points[idx]['h']*detectImgHeight),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: const Color(0xffe8e0fe),
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

    String url = 'http://namuintell.iptime.org:16000/v2/models/detectionModel/versions/1/infer';

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

    String currTime = DateFormat('yyyyMMddhhmm_ss').format(DateTime.now());
    var extPath = path.join((await getExternalStorageDirectory())!.path, 'MyApp', '${currTime}_detectSave.png');

    var tmpBox = [];
    // for (var i in boxData) {
    //   tmpBox.add(jsonEncode(i));
    // }

    File file = new File(extPath);
    file.writeAsBytesSync(_image!.readAsBytesSync());

    var results = await conn.query('INSERT INTO images (img_path, position) VALUES (?, ?)', ['${extPath}', '${jsonEncode(boxData)}']);

    setState(() => isDetect = false);
  }

  GlobalKey imageBox = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: const Color(0xff5f6062)
          ),
          backgroundColor: const Color(0xffe8e0fe),
          title: Text('미리보기', style: TextStyle(color: const Color(0xff5f6062), fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        body: Stack(
          children: [
            Container(
              key: imageBox,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.file(_image!, fit: BoxFit.fill),
            ),
            if (renderBox != null) ...generateRect(boxData),
            isComplete ? Container(
              padding: EdgeInsets.only(bottom: 50),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                      color: const Color(0xffe8e0fe),
                      onPressed: backwardPage,
                      child: Text('다시찍기', style: TextStyle(color: const Color(0xff5f6062), fontWeight: FontWeight.bold))
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  isDetect ? RaisedButton(
                      color: const Color(0xffe8e0fe),
                      onPressed: saveAction,
                      child: Text('저장하기', style: TextStyle(color: const Color(0xff5f6062), fontWeight: FontWeight.bold))
                  ) : RaisedButton(
                      color: const Color(0xffe8e0fe),
                      onPressed: detectAction,
                      child: Text('디텍팅하기', style: TextStyle(color:  const Color(0xff5f6062), fontWeight: FontWeight.bold))
                  ),
                ],
              ),
            ) : CircularProgressIndicator(),
          ],
        )
    );
  }
}
