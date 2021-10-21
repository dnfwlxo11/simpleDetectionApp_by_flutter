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
  List imgList = [];
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
    // GallerySaver.saveImage(file.path);
    file.delete();
    getImages();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget itemCard(image) {
    print(image.statSync());
    return Column(
        children: [
          Stack(
            children: [
                  Image.file(
                    image,
                    fit: BoxFit.fitHeight,
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => removeFile(image),
                    child: Container(
                      padding: EdgeInsets.only(right: 10, top: 10),
                      child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30
                      ),
                    )
                  )
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${DateFormat('yy/MM/dd HH:mm:ss').format(image.statSync().accessed)}',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  )
              ),
            ],
          ),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GridView.builder(
            itemCount: imgList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: const Color(0xffffdc7c),
                  child: itemCard(imgList[index]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),

                ),
                onTap: () => detailInfo(context, imgList[index]),
              );
            }
        )
    );
  }
}
