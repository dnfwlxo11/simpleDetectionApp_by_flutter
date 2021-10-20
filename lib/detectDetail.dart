import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as crop;
import 'package:mysql1/mysql1.dart';

class DetectDetail extends StatefulWidget {
  final imgData;

  const DetectDetail({Key? key, required this.imgData}) : super(key: key);

  @override
  _DetectDetailState createState() => _DetectDetailState();
}

class _DetectDetailState extends State<DetectDetail> {
  var conn;
  var labelMap;

  RenderBox? renderBox;
  double detectImgWidth = 0.0;
  double detectImgHeight = 0.0;
  bool isLoaded = false;

  ScrollController sc = new ScrollController();
  PanelController pc = new PanelController();
  File? _image;

  List boxData = [];

  @override
  void initState() {
    super.initState();

    initDb();
    setState(() { _image = widget.imgData; });
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        renderBox = imageBox.currentContext!.findRenderObject() as RenderBox;
        detectImgWidth = renderBox!.size.width;
        detectImgHeight = renderBox!.size.height;
        isLoaded = true;
      });
    });
    getLabelMap();
  }

  void getLabelMap() async {
    var tmp = json.decode(await rootBundle.loadString('assets/labelMap.json'));
    setState(() => labelMap = tmp);
  }

  void initDb() async {
    var mysqlSetting = new ConnectionSettings(
        host: '192.168.0.106',
        port: 3306,
        user: 'root',
        password: '1234#',
        db: 'detection'
    );

    conn = await MySqlConnection.connect(mysqlSetting);
    getDetectBox();
  }

  void getDetectBox() async {
    var results = (await conn.query('SELECT position FROM images where img_path = ?', ['${_image!.path}'])).toList();
    setState(() => boxData = jsonDecode(results[0]['position']).map((e) => jsonDecode(e)).toList());
    print(boxData);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _image = null;
    super.dispose();
  }

  void showDetailDetection(points) async {
    var bytes = _image!.readAsBytesSync();
    final extDir = await getExternalStorageDirectory();

    double imageWidth = renderBox!.size.width;
    double imageHeight = renderBox!.size.height;

    var tmpPath = extDir!.path + '/MyApp/tmp.png';

    crop.Image? image = await crop.decodeImage(bytes);
    crop.Image cropped = await crop.copyCrop(image!, (points['x']*image.width).toInt(), (points['y']*image.height).toInt(), (points['w']*image.width).toInt(), (points['h']*image.height).toInt());

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
                  child: Image.memory(
                    Uint8List.fromList(crop.encodePng(cropped)),
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
                '${labelMap['${points[idx]['class']}']}',
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
      List<Widget> detectListTile = List.generate(detects.length, (idx) {
          return ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 6.0),
            leading: Icon(Icons.food_bank),
            title: Text('${labelMap['${detects[idx]['class']}']}'),
            onTap: () => showDetailDetection(detects[idx]),
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
          if (renderBox != null) ...generateRect(boxData),
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

        panel: detectList(boxData),
        body: bodyWidget(),
      ),
    );
  }
}