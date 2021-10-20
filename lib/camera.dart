import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:simple_detection_app/cameraDetail.dart';

import 'dart:async';


class Camera extends StatefulWidget {
  const Camera({Key? key,}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
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
  }

  getLabelMap() async {
    var tmp = json.decode(await rootBundle.loadString('assets/labelMap.json'));
    log(tmp.toString());
    log('json');
    setState(() => labelMap = tmp);
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              FutureBuilder<void> (
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller!);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              Positioned(
                bottom: 40,
                right: 10,
                child: FloatingActionButton(
                  child: Icon(Icons.camera_alt),
                  onPressed: () async {
                    try {
                      await _initializeControllerFuture;

                      final path = join(
                        (await getExternalStorageDirectory())!.path,
                        'MyApp'
                      );

                      await Directory(path).create();
                      String currTime = DateFormat('yyyyMMddhhmm').format(DateTime.now());

                      XFile picture = await _controller!.takePicture();
                      picture.saveTo(join(path, '${currTime}Detect.png'));

                      // await GallerySaver.saveImage(path, albumName: 'MyApp');

                      String imagePath = '$path/${currTime}Detect.png';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraDetail(imagePath: imagePath),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ),
            ],
          )
      ),
    );
  }
}