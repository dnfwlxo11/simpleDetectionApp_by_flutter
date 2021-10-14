import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:image/image.dart' as cropLib;

class DetectDetail extends StatefulWidget {
  final imgData;

  const DetectDetail({Key? key, required this.imgData}) : super(key: key);

  @override
  _DetectDetailState createState() => _DetectDetailState();
}

class _DetectDetailState extends State<DetectDetail> {

  PanelController pc = new PanelController();
  File? _image;

  var detectSample = [
    {
      'class': '사람',
      'x': 10,
      'y': 10,
      'w': 200,
      'h': 170,
    },
    {
      'class': '동물',
      'x': 80,
      'y': 400,
      'w': 100,
      'h': 100,
    },
    {
      'class': '자동차',
      'x': 240,
      'y': 200,
      'w': 90,
      'h': 90,
    },
    {
      'class': '콜라',
      'x': 210,
      'y': 370,
      'w': 170,
      'h': 130,
    },
  ];

  void saveDetectResult() {

  }


  void showDetailDetection(points) async {
    // cropLib.Image cropped = cropLib.copyCrop(Image.file(widget.imgData), 10, 10, 200, 170);
    //
    // Image croppedImage = Image.memory(cropLib.encodePng(cropped));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(points['class']),
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 4.0 / 3.0,
                  child: Image.file(
                    _image!,
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

  Widget generateRect(points) {
    return new Positioned(
      left: points['x'].toDouble(),
      top: points['y'].toDouble(),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(7),
            child: Text(
              '${points['class']}',
              style: TextStyle(fontSize: 20),
            ),
            color: Colors.blue,
          ),
          InkWell(
            child: Container(
              width: points['w'].toDouble(),
              height: points['h'].toDouble(),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Colors.blue,
                ),
              ),
            ),
            onTap: () => showDetailDetection(points),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    setState(() { _image = widget.imgData; });
  }

  @override
  Widget build(BuildContext context) {
    Widget detectList(detects) {
      List<Widget> detectListTile = List.generate(detects.length, (idx) {
          return ListTile(
            leading: Icon(Icons.food_bank),
            title: Text('${detects[idx]['class']}'),
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
              children: ListTile.divideTiles(
                  context: context,
                  tiles: List.generate(detects.length, (idx) {
                    return ListTile(
                      leading: Icon(Icons.food_bank),
                      title: Text('${detects[idx]['class']}'),
                      onTap: () => showDetailDetection(detects[idx]),
                    );
                  })
              ).toList(),
            )
        ),
      );
    }

    Widget collapseWidget() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
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
      );
    }

    Widget bodyWidget() {
      return Card(
        child: Container(
            child: Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 3.0 / 4.0,
                  child: Image.file(_image!, fit: BoxFit.fill),
                ),
                for (var i in detectSample) generateRect(i)
              ],
            )
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(title: Text('자세히 보기')),
      body: SlidingUpPanel(
        header: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
            ),
            margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
            child: Text('안녕')
        ),
        controller: pc,
        minHeight: 100,
        renderPanelSheet: false,
        borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0)
        ),

        collapsed: collapseWidget(),

        panel: Container(
          child: detectList(detectSample),
        ),


        body: bodyWidget(),
      ),
    );
  }
}