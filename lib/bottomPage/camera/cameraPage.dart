import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_detection_app/bottomPage/camera/detail/cameraDetail.dart';

import 'dart:async';

import 'package:simple_detection_app/utils/toast.dart';


class CameraPage extends StatefulWidget {
  const CameraPage({Key? key,}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  var _saveImage;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  var labelMap;

  void _cameraInit() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(
      camera,
      ResolutionPreset.veryHigh,
    );

    _initializeControllerFuture = _controller!.initialize();

    _controller!.setFlashMode(FlashMode.off);
  }

  @override
  void initState() {
    super.initState();
    _cameraInit();
    getLabelMap();
    PaintingBinding.instance!.imageCache!.clear();
    PaintingBinding.instance!.imageCache!.clearLiveImages();
  }

  getLabelMap() async {
    var tmp = json.decode(await rootBundle.loadString('assets/labelMap.json'));
    setState(() => labelMap = tmp);
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    PaintingBinding.instance!.imageCache!.clear();
    _controller!.dispose();
    super.dispose();
  }

  Future<String> takePicture() async {
    await _initializeControllerFuture;

    final path = join(
        (await getExternalStorageDirectory())!.path,
        'MyApp'
    );

    await Directory(path).create();
    String currTime = await DateFormat('yyyyMMddhhmm_ss').format(DateTime.now());

    XFile picture = await _controller!.takePicture();
    await picture.saveTo(join(path, '${currTime}Detect.png'));

    String imagePath = await '$path/${currTime}Detect.png';

    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    void loadImageByGallery() async {
      PickedFile? image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      if (image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraDetail(imagePath: image.path),
          ),
        );
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder<void> (
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: FloatingActionButton(
                      backgroundColor: Color(0xff5293c9),
                      child: Icon(Icons.camera_alt, color: Color(0xffeeeeee)),
                      onPressed: () async {
                        String imagePath = await takePicture();

                        print(imagePath);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CameraDetail(imagePath: imagePath),
                          ),
                        );
                        // Navigator.pushNamed(context, '/camera');
                      }
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 20, right: 10),
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FlatButton(
                  color: Color(0xff5293c9),
                  onPressed: () => loadImageByGallery(),
                  child: Text(
                      '내 사진 가져오기',
                      style: TextStyle(
                          color: Color(0xffeeeeee),
                          fontWeight: FontWeight.bold
                      )
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}