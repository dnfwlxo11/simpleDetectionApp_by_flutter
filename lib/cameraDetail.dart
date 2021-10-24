import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

  List<int> classFilter(List<List<double>> classData) {
    List<int> classes = [];

    // 2차원 기본 배열 생성
    List<List<double>> classAxis1 = List.generate(25200, (i) => List.generate(classData.length, (j) => 0));

    for (var i=0;i<classData.length;i++) {
      for (var j=0;j<classData[i].length;j++) {
        classAxis1[j][i] = classData[i][j];
      }
    }

    for (var i=0;i<classAxis1.length;i++) {
      classes.add(classAxis1[i].indexOf(classAxis1[i].reduce(max)));
    }
    
    return classes;
  }

  List<List<double>> convert2dArr(List<double> array) {
    List<List<double>> arr2D = [];
    for (var i = 0;i<155; i++) {
      arr2D.add(array.sublist(i*25200, (i+1)*25200));
    }

    return arr2D;
  }

  List<List> convertOutput(List<double> outputData) {
    List<List<double>> arr2D = convert2dArr(outputData);

    // get Boxs
    List boxes = arr2D.sublist(0, 4);

    // get Scores
    List scores = arr2D.sublist(4, 5);

    // get classes
    List<List<double>> classes = arr2D.sublist(5, 155);
    List classFiltered = classFilter(classes);

    return [boxes, scores, classFiltered];
  }

  Future<File> getNetworkFile(url) async {
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(path.join(documentDirectory.path, 'networkImage.png'));

    file.writeAsBytesSync(response.bodyBytes);

    return file;
  }

  void detectAction() async {
    setState(() => isComplete = false);
    setState(() => isDetect = false);

    // String url = 'http://namuintell.iptime.org:16000/v2/models/detectionModel/versions/1/infer';
    String url = 'http://namuintell.iptime.org:16000/v2/models/ezfit/versions/1/infer';

    // var bytes = _image!.readAsBytesSync().buffer.asUint8List();

    var networkFile = await getNetworkFile('https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAxOTA4MDhfMTcx%2FMDAxNTY1MjI5Mzc5MzA5.f9jpsIedC7MmUcla9WoGUFZfzwyciqiIn11rf-WKfwog.qbXKo9O4MAhVOg1HEnV0fM1DvidI-YWO0LQ3R2ZchiYg.JPEG.msinvestment%2F%25BD%25C3%25B1%25D7%25B4%25CF%25C3%25B3%25C7%25C7%25C0%25DA07287.jpg&type=sc960_832');
    var bytes = networkFile.readAsBytesSync().buffer.asUint8List();

    crop.Image? image = await crop.decodeImage(bytes);
    var resizeImage = crop.copyResize(image!, width: 640, height: 640);
    var decodeBytes = resizeImage.getBytes(format: crop.Format.rgb);

    print(decodeBytes);

    var body = jsonEncode({
      "inputs": [
        {
          // "name": "image_arrays:0",
          // "datatype": "UINT8",
          // "shape": [1, resizeImage.height, resizeImage.width, 3],
          "name": "images",
          "datatype": "FP32",
          "shape": [1, 3, resizeImage.height, resizeImage.width],
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
    // print(predict.sublist(0, 100));
    // print(predict.sublist(25200, 25300));

    var output = convertOutput(predict.cast<double>());
    print(output[1][0]);

    for (var i=0;i<output[1][0].length;i++) {
      if (output[1][0][i] <= 1.0 && output[1][0][i] >= 0.7) {
        double x = output[0][0][i];
        double y = output[0][1][i];
        double w = output[0][2][i];
        double h = output[0][3][i];

        print('class: ' + output[2][i].toString());
        print('confidence: ' + output[1][0][i].toString());
        print('position: ' + '${x}, ${y}, ${w}, ${h}');
      };
    }

    // 좌표, 점수, 클래스

    // setState(() => boxData = []);
    // for (var i=0;i<((predict.length)/7).toInt();i++) {
    //   var predictArr = predict.sublist(0 + (i * 7), 7 + (i * 7));
    //   if (predictArr[5] < 0.3) break;
    //   setState(() {
    //     boxData.add({
    //       'class': predictArr[6].toInt(),
    //       'x': predictArr[2] / resizeImage.width,
    //       'y': predictArr[1] / resizeImage.height,
    //       'w': (predictArr[4] - predictArr[2]) / resizeImage.width,
    //       'h': (predictArr[3] - predictArr[1]) / resizeImage.height,
    //     });
    //   });
    // }

    // setState(() => isDetect = true);
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
