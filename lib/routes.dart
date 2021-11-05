import 'package:flutter/material.dart';

import 'package:simple_detection_app/utils/splash_page.dart';
import 'package:simple_detection_app/bottomPage/gallery/gallery_page.dart';
import 'package:simple_detection_app/bottomPage/camera/camera_page.dart';
import 'package:simple_detection_app/bottomPage/camera/detail/camera_detail.dart';
import 'package:simple_detection_app/bottomPage/bottom_page_view.dart';
import 'package:simple_detection_app/bottomPage/main/detail/content.dart';

final routes = <String, WidgetBuilder>{
  '/': (BuildContext context) => SplashPage(),
  '/gallery': (BuildContext context) => GalleryPage(),
  '/camera': (BuildContext context) => CameraPage(),
  '/menu': (BuildContext context) => HomePage(),
  '/content': (BuildContext context) => Content(),
};