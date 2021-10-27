import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_detection_app/bottomPage/bottomPageView.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(milliseconds: 4000),
            () => Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/splashCharacter.jpg'),
              Text(
                  '스마트한 생활습관',
                  style: TextStyle(
                    fontSize: 20
                  )
              )
            ],
          )
      ),
    );
  }
}
