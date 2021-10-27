import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message) {
  Fluttertoast.showToast(
      textColor: Colors.black,
      msg: message,
      backgroundColor: Color(0xffeeeeee),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM
  );
}