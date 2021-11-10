import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as crop;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:simple_detection_app/detectionModelFunc/yolov5.dart' as yolo;
import 'package:simple_detection_app/detectionModelFunc/efficient_det.dart' as efficient;
import 'package:simple_detection_app/utils/progress_spinkit.dart' as spinkit;
import 'package:simple_detection_app/utils/toast.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:simple_detection_app/config.dart' as DB;


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

  @override
  void initState() {
    super.initState();
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

  void detectAction_server() async {
    setState(() => isComplete = false);
    setState(() => isDetect = false);
    setState(() => boxData = []);

    // 일반 모델
    // example) http://localhost:8080/inference
    // String url = DB.getEfficientURL();

    // ezfit 모델
    String url = DB.getYoloURL();

    // ezfit 모델을 사용하려면 efficient 단어를 모두 yolo로 변경하면됨
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

  // 현재 ezfit 모델은 핸드폰 내부 모드는 지원하지 않음
  void detectAction_inner() async {
    setState(() => isComplete = false);
    setState(() => isDetect = false);
    setState(() => boxData = []);

    crop.Image? image = crop.decodeImage(_image!.readAsBytesSync());
    crop.Image? resizeImage = crop.copyResize(image!, width: 640, height: 640);

    final model  = await tfl.Interpreter.fromAsset('model.tflite');

    efficient.setTargetImage(_image);
    var data = await efficient.getImageBytes();

    var input = Uint8List.fromList(data);
    var output = List.filled(1*100*7, 0).reshape([1,100,7]);

    model.run(input, output);

    model.close();

    setState(() => boxData = efficient.convertOutput_inner(output[0]));

    setState(() => isDetect = true);
    setState(() => isComplete = true);
  }

  void backwardPage() {
    Navigator.pop(context);
  }

  /* mysql start example
   * var setting = new ConnectionSettings(
   *  host: ''
   *  port:
   *  user: ''
   *  password: ''
   *  db: ''
   * );
   *
   * conn = await MySqlConnection.connect(setting);
   *
   * await conn.query('INSERT INTO TEST(value1, value2) VALUES (?, ?)', [value1, value2]);
   */
  void saveAction() async {
    showToast('이미지 저장');

    String currTime = DateFormat('yyyyMMddhhmm_ss').format(DateTime.now());
    var extPath = path.join((await getExternalStorageDirectory())!.path, 'MyApp', '${currTime}_detectSave.png');

    File file = new File(extPath);
    file.writeAsBytesSync(_image!.readAsBytesSync());

    var results = await DB.Database.instance.insertImages(extPath, jsonEncode(boxData));

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
                      onPressed: detectAction_server,
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
