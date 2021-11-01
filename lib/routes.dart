import 'package:flutter/material.dart';

import 'package:simple_detection_app/utils/splashPage.dart';
import 'package:simple_detection_app/bottomPage/gallery/galleryPage.dart';
import 'package:simple_detection_app/bottomPage/camera/cameraPage.dart';
import 'package:simple_detection_app/bottomPage/bottomPageView.dart';
import 'package:simple_detection_app/bottomPage/main/detail/content.dart';

final routes = <String, WidgetBuilder>{
  '/': (BuildContext context) => SplashPage(),
  '/gallery': (BuildContext context) => GalleryPage(),
  '/camera': (BuildContext context) => CameraPage(),
  '/menu': (BuildContext context) => HomePage(),
  '/content': (BuildContext context) => Content(),
};