import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_detection_app/detectDetail.dart';


class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List? imgList;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    if (isLoading) CircularProgressIndicator();

    getImages();

    super.initState();
  }

  void getImages() async {
    final extDir = await getExternalStorageDirectory();

    final files = await new Directory(join(extDir!.path, 'MyApp'));

    List<FileSystemEntity> _files = files.listSync();

    isLoading = false;
    setState(() { imgList = _files; });
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.lightBlue,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        gravity: ToastGravity.BOTTOM
    );
  }

  void detailInfo(context, data) {
    // showToast(index.toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectDetail(imgData: data),
      ),
    );
  }

  void removeFile(File file) {
    file.delete();
    getImages();
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
            return Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: InkWell(
                onTap: () => detailInfo(context, imgList![index]),
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
                              child: InkWell(
                                onTap: () => removeFile(imgList![index]),
                                child: Icon(Icons.delete),
                              )
                            ),
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
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 3,
              margin: EdgeInsets.all(10),
            );
          }),
        ),
      ),
    );
  }
}
