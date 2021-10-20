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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _image = null;
    super.dispose();
  }

  void showDetailDetection(points) async {
    print('부른다');

    var bytes = _image!.readAsBytesSync();

    crop.Image? image = await crop.decodeImage(bytes);
    crop.Image cropped = await crop.copyCrop(image!, (points['x']*image.width).toInt(), (points['y']*image.height).toInt(), (points['w']*image.width).toInt(), (points['h']*image.height).toInt());

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(labelMap['${points['class']}']),
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
                style: TextStyle(fontSize: 20, color: Colors.white),
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
              // onTap: () => showDetailDetection(points[idx]),
            ),
          ],
        ),
      );
    });
  }

  GlobalKey imageBox = GlobalKey();

  @override
  Widget build(BuildContext context) {
    List<Widget> detectListTile(detects) {
      return [
        Container(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 18.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
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
        ...List.generate(detects.length, (idx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 18.0),
          child: ListTile(
            leading: Icon(Icons.food_bank),
            title: Text('${labelMap['${detects[idx]['class']}']}'),
            onTap: () => showDetailDetection(detects[idx]),
          ),
        );
      }).toList()
      ];
    }

    Widget detectList(detects, ScrollController sc) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.grey,
              ),
            ]
        ),
        margin: const EdgeInsets.all(18.0),
        child: ListView(
          controller: sc,
          children: ListTile.divideTiles(
              context: context,
              tiles: <Widget>[

                ...detectListTile(detects)
              ]
          ).toList(),
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

    Widget collapseWidget() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        ),
        margin: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
        child: Column(
          children: [
            Expanded(
                child: Center(
                  child: Icon(Icons.keyboard_arrow_up, size: 40, color: Colors.white,),
                ),
            ),
            Expanded(
              child: Text(
                "분석 결과",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(title: Text('자세히 보기')),
      body: SlidingUpPanel(
        backdropEnabled: true,
        controller: pc,
        renderPanelSheet: false,
        borderRadius:  BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),

        collapsed: collapseWidget(),

        panelBuilder: (sc) => detectList(boxData, sc),
        body: bodyWidget(),
      ),
    );
  }
}