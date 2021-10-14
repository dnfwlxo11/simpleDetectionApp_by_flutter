import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DetectDetail extends StatefulWidget {
  final imgData;

  const DetectDetail({Key? key, required this.imgData}) : super(key: key);

  @override
  _DetectDetailState createState() => _DetectDetailState();
}

class _DetectDetailState extends State<DetectDetail> {

  var detectSample = [
    {
      'class': '사람',
      'x': 10,
      'y': 10,
      'w': 100,
      'h': 100,
    },
    {
      'class': '동물',
      'x': 50,
      'y': 50,
      'w': 60,
      'h': 80,
    },
    {
      'class': '자동차',
      'x': 70,
      'y': 20,
      'w': 120,
      'h': 80,
    },
    {
      'class': '콜라',
      'x': 25,
      'y': 55,
      'w': 120,
      'h': 80,
    },
  ];

  void saveDetectResult() {

  }

  void previewCropImage() {

  }

  Widget generateRect(points) {
    print(points['x'].toDouble() is double);
    return new Positioned(
      left: points['x'].toDouble(),
      top: points['y'].toDouble(),
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
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget detectList(detects) {
      return Column(
        children: List.generate(detects.length, (index) {
          return ListTile(
            leading: Icon(Icons.food_bank),
            title: Text('${detects[index]['class']}'),
          );
        }),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(title: Text('자세히 보기')),
      body: SlidingUpPanel(
        borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0)
        ),
        panel: Container(
          child: detectList(detectSample),
        ),

        collapsed: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Icon(Icons.keyboard_arrow_up, size: 50, color: Colors.white,),
              ),
              Text(
                "음식 분석 결과",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),

        body: Card(
          child: Container(
              child: Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 3.0 / 4.0,
                    child: Image.file(widget.imgData, fit: BoxFit.fill),
                  ),
                  for (var i in detectSample) generateRect(i)
                ],
              )
          ),
        ),
      ),
    );
  }
}