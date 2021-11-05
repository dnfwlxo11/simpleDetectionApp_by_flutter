import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_detection_app/bottomPage/gallery/detail/detect_detail.dart';


class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
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
    return Column(
        children: [
          Expanded(
            flex: 8,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  child: Image.file(
                    image,
                    fit: BoxFit.fill,
                  ),
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
                              color: Color(0xffeeeeee),
                              size: 30
                          ),
                        )
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${DateFormat('yy/MM/dd HH:mm:ss').format(image.statSync().accessed)}',
                    style: TextStyle(
                        color: Color(0xffeeeeee),
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    )
                ),
              ],
            ),
          )
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 30),
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                child: Text('보관함',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 40
                    )
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20),
              ),
              Expanded(
                child: GridView.builder(
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
                        color: Color(0xff5293c9),
                        child: itemCard(imgList[index]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onTap: () => detailInfo(context, imgList[index]),
                    );
                  },
                ),
              )
            ],
          )
      ),
    );
  }
}
