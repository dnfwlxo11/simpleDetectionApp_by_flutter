import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as crop;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:simple_detection_app/detectionModelFunc/yolov5.dart' as yolo;
import 'package:simple_detection_app/detectionModelFunc/efficientDet.dart' as efficient;
import 'package:simple_detection_app/utils/progressSpinkit.dart' as spinkit;
import 'package:simple_detection_app/utils/toast.dart';

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
    // var tmp = jsonDecode(await rootBundle.loadString('assets/labelMap.json'));
    var tmp = jsonDecode(await rootBundle.loadString('assets/labelMap2.json'));
    setState(() => labelMap = tmp);
  }

  @override
  void dispose() {
    _image!.deleteSync();
    super.dispose();
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
                // '${points[idx]['class']}',
                style: TextStyle(fontSize: 20, color: Color(0xffeeeeee)),
              ),
              color: Color(0xff5293c9),
            ),
            Container(
              width: (points[idx]['w']*detectImgWidth),
              height: (points[idx]['h']*detectImgHeight),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Color(0xff5293c9),
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
    setState(() => boxData = []);

    // String url = 'http://namuintell.iptime.org:16000/v2/models/detectionModel/versions/1/infer';
    String url = 'http://namuintell.iptime.org:16000/v2/models/ezfit/versions/1/infer';

    yolo.setTargetImage(_image);
    var data = await yolo.getImageBytes();
    var body = yolo.getRequestBody(data);

    var response = await http.post(
        Uri.parse(url),
        body: body
    );

    var predict = jsonDecode(response.body)['outputs'][0]['data'];

    setState(() => boxData = yolo.convertOutput(predict));

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
            color: Color(0xffeeeeee)
          ),
          backgroundColor: Color(0xff5293c9),
          title: Text('미리보기', style: TextStyle(color: Color(0xffeeeeee), fontWeight: FontWeight.bold, fontSize: 20)),
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
                      color: Color(0xff5293c9),
                      onPressed: backwardPage,
                      child: Text('다시찍기', style: TextStyle(color: Color(0xffeeeeee), fontWeight: FontWeight.bold))
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  isDetect ? RaisedButton(
                      color: Color(0xff5293c9),
                      onPressed: saveAction,
                      child: Text('저장하기', style: TextStyle(color: Color(0xffeeeeee), fontWeight: FontWeight.bold))
                  ) : RaisedButton(
                      color: Color(0xff5293c9),
                      onPressed: detectAction,
                      child: Text('디텍팅하기', style: TextStyle(color:  Color(0xffeeeeee), fontWeight: FontWeight.bold))
                  ),
                ],
              ),
            ) : Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spinkit.pouringHourGlassRefined
                ],
              ),
            ),
          ],
        )
    );
  }
}
