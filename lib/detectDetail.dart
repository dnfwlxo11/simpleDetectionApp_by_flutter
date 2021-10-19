import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as crop;

class DetectDetail extends StatefulWidget {
  final imgData;

  const DetectDetail({Key? key, required this.imgData}) : super(key: key);

  @override
  _DetectDetailState createState() => _DetectDetailState();
}

class _DetectDetailState extends State<DetectDetail> {
  RenderBox? renderBox;
  double detectImgWidth = 0.0;
  double detectImgHeight = 0.0;
  bool isLoaded = false;

  ScrollController sc = new ScrollController();
  PanelController pc = new PanelController();
  File? _image;

  var detectSample = [];

  @override
  void initState() {
    super.initState();

    setState(() { _image = widget.imgData; });
    // final RenderBox renderBox = imageBox.currentContext!.findRenderObject() as RenderBox;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        renderBox = imageBox.currentContext!.findRenderObject() as RenderBox;
        detectImgWidth = renderBox!.size.width;
        detectImgHeight = renderBox!.size.height;
        isLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _image = null;
    super.dispose();
  }

  void addPredict() {
    setState(() {
      detectSample.add({
        'class': '사람',
        'x': 0.0,
        'y': 0.0,
        'w': 0.25,
        'h': 0.25,
      });

      detectSample.add({
        'class': '동물',
        'x': 0.25,
        'y': 0.25,
        'w': 0.25,
        'h': 0.25,
      });

      detectSample.add({
        'class': '자동차',
        'x': 0.5,
        'y': 0.5,
        'w': 0.25,
        'h': 0.25,
      });

      detectSample.add({
        'class': '콜라',
        'x': 0.75,
        'y': 0.75,
        'w': 0.25,
        'h': 0.25,
      });
    });
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

    for (var i in boxData) {
      if (i[5] < 0.3) break;
      print('좌표: ${i.sublist(1, 5)}');
      print('정확도: ${i[5]}');
      print('클래스 인덱스: ${i[6]}');
    }
  }

  Future<File> saveAndLoadDetectImage(String path, crop.Image data) async {
    new FileImage(File(path)).evict();
    new File(path).writeAsBytesSync(crop.encodePng(data));

    return File(path);
  }

  void showDetailDetection(points) async {
    var bytes = _image!.readAsBytesSync();
    var realImage = await decodeImageFromList(bytes);
    final extDir = await getExternalStorageDirectory();

    double imageWidth = renderBox!.size.width;
    double imageHeight = renderBox!.size.height;

    var tmpPath = extDir!.path + '/MyApp/tmp.png';

    crop.Image? image = await crop.decodeImage(bytes);
    image = await crop.copyResize(image!, width: (imageWidth).toInt(), height: (imageHeight).toInt());
    crop.Image cropped = await crop.copyCrop(image, (points['x']*imageWidth).toInt(), (points['y']*imageHeight).toInt(), (points['w']*imageWidth).toInt(), (points['h']*imageHeight).toInt());


    File? croppedImage = await saveAndLoadDetectImage(tmpPath, cropped);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(points['class']),
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 3.0 / 4.0,
                  child: Image.file(
                    croppedImage,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: new Text("Close"),
              ),
            ],
          );
        }
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
                '${points[idx]['class']}',
                style: TextStyle(fontSize: 20),
              ),
              color: Colors.blue,
            ),
            InkWell(
              child: Container(
                width: (points[idx]['w']*detectImgWidth),
                height: (points[idx]['h']*detectImgHeight),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.blue,
                  ),
                ),
              ),
              onTap: () => showDetailDetection(points[idx]),
            ),
          ],
        ),
      );
    });
  }

  GlobalKey imageBox = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Widget detectList(detects) {
      addPredict();
      List<Widget> detectListTile = List.generate(detects.length, (idx) {
          return ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 6.0),
            leading: Icon(Icons.food_bank),
            title: Text('${detects[idx]['class']}'),
            // onTap: () => showDetailDetection(detects[idx]),
            onTap: () => addPredict(),
          );
        }).toList();

      return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.grey,
              ),
            ]
        ),
        margin: const EdgeInsets.all(24.0),
        child: Container(
            child: ListView(
              controller: sc,
              children: ListTile.divideTiles(
                  context: context,
                  tiles: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Icon(Icons.keyboard_arrow_up, size: 40, color: Colors.white,),
                          ),
                          Text(
                            "분석 결과",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    ...detectListTile
                  ]
              ).toList(),
            )
        ),
      );
    }

    Widget bodyWidget() {
      return Stack(
        children: <Widget>[
          Container(
            key: imageBox,
            child: AspectRatio(
              aspectRatio: 3.0 / 4.0,
              child: Image.file(_image!, fit: BoxFit.fill),
            ),
          ),
          if (renderBox != null) ...generateRect(detectSample),
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(title: Text('자세히 보기')),
      body: SlidingUpPanel(
        controller: pc,
        renderPanelSheet: false,
        borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0)
        ),

        // collapsed: collapseWidget(),

        panel: detectList(detectSample),
        body: bodyWidget(),
      ),
    );
  }
}