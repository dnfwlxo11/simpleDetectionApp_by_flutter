import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_detection_app/cameraDetail.dart';
import 'dart:async';


class Camera extends StatefulWidget {
  const Camera({Key? key,}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

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
    // TODO: implement initState;

    _cameraInit();
    super.initState();
  }

  @override
  void dispose() {
    // 위젯의 생명주기 종료시 컨트롤러 역시 해제시켜줍니다.
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
                    // Future가 완료되면, 프리뷰를 보여줍니다.
                    return CameraPreview(_controller!);
                  } else {
                    // Otherwise, display a loading indicator.
                    // 그렇지 않다면, 진행 표시기를 보여줍니다.
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              Positioned(
                bottom: 40,
                right: 10,
                child: FloatingActionButton(
                  child: Icon(Icons.camera_alt),
                  // onPressed 콜백을 제공합니다.
                  onPressed: () async {
                    // try / catch 블럭에서 사진을 촬영합니다. 만약 뭔가 잘못된다면 에러에
                    // 대응할 수 있습니다.
                    try {
                      // 카메라 초기화가 완료됐는지 확인합니다.
                      await _initializeControllerFuture;

                      print((await getExternalStorageDirectory())!.path);
                      // path 패키지를 사용하여 이미지가 저장될 경로를 지정합니다.
                      final path = join(
                        // 본 예제에서는 임시 디렉토리에 이미지를 저장합니다. `path_provider`
                        // 플러그인을 사용하여 임시 디렉토리를 찾으세요.
                        (await getExternalStorageDirectory())!.path,
                        '${DateTime.now()}.png',
                      );

                      XFile picture = await _controller!.takePicture();
                      picture.saveTo(path);

                      // 사진 촬영을 시도하고 저장되는 경로를 로그로 남깁니다.
                      // await _controller!.takePicture(path);

                      // 사진을 촬영하면, 새로운 화면으로 넘어갑니다.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraDetail(imagePath: path),
                        ),
                      );
                    } catch (e) {
                      // 만약 에러가 발생하면, 콘솔에 에러 로그를 남깁니다.
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