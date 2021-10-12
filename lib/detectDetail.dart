import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetectDetail extends StatefulWidget {
  final imgData;

  const DetectDetail({Key? key, required this.imgData}) : super(key: key);

  @override
  _DetectDetailState createState() => _DetectDetailState();
}

class _DetectDetailState extends State<DetectDetail> {

  void setData() {
    print(widget.imgData);
  }

  @override
  void initState() {
    // TODO: implement initState
    setData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(title: Text('자세히 보기')),
      body: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child:
              Container(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 3.0 / 4.0,
                  child: Image.file(widget.imgData, fit: BoxFit.fill),
                ),
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 2,
              child:
              Container(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 3.0 / 4.0,
                  child: Text('${DateFormat('yyyy년 MM월 dd일 hh시 mm분 ').format(widget.imgData.statSync().accessed)}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
