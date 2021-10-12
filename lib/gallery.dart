import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List? imgList;

  final sampleImg = [
    {'image': 'assets/img1.png', 'name': '무등산'},
    {'image': 'assets/img2.png', 'name': '백두산'},
    {'image': 'assets/img3.png', 'name': '한라산'},
    {'image': 'assets/img4.png', 'name': '지리산'},
    {'image': 'assets/img1.png', 'name': '무등산'},
    {'image': 'assets/img2.png', 'name': '백두산'},
    {'image': 'assets/img3.png', 'name': '한라산'},
    {'image': 'assets/img4.png', 'name': '지리산'},
  ];

  @override
  void initState() {
    // TODO: implement initState
    getImages();

    super.initState();
  }

  void getImages() async {
    String extDir = (await getExternalStorageDirectory())!.path;

    final files = new Directory(join(extDir, 'MyApp'));

    List<FileSystemEntity> _files = files.listSync();

    _files.forEach((item) {
      print(item.statSync().accessed);
    });

    print(_files);

    setState(() { imgList = _files; });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          // crossAxisCount: 1,
          children: List.generate(imgList!.length, (index) {
            return Container(
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        child: AspectRatio(
                          aspectRatio: 3.0 / 4.0,
                          child: Image.file(
                            imgList![index],
                            fit: BoxFit.fill,
                          ),
                        ),
                        padding: EdgeInsets.all(10.0),
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(3),
                            child: Text('생성일'),
                          ),
                          Padding(
                            padding: EdgeInsets.all(3),
                            child: Text('${DateFormat('yyyy년 MM월 dd일 hh시 mm분 ').format(imgList![index].statSync().accessed)}'),
                          ),
                        ],
                      )
                    )
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 3,
                margin: EdgeInsets.all(10),
              ),
            );
          }),
        ),
      ),
    );
  }
}
