import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final sampleImg = [
      {'image': 'assets/img1.png', 'name': '무등산'},
      {'image': 'assets/img2.png', 'name': '백두산'},
      {'image': 'assets/img3.png', 'name': '한라산'},
      {'image': 'assets/img4.png', 'name': '지리산'},
  ];

  void getImages() async {
    print((await getApplicationDocumentsDirectory()).path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(sampleImg.length, (index) {
            return Card(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset('${sampleImg[index]['image']}'),
                    Text('${sampleImg[index]['name']}'),
                    RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: getImages,
                      child: Text('자세히보기'),
                    ),
                  ],
                ),
              )
            );
          }),
        ),
      ),
    );
  }
}
