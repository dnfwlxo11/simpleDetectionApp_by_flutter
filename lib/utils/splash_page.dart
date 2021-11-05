import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_detection_app/bottomPage/bottom_page_view.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Image? splashLogo;
  
  @override
  void initState() {
    super.initState();
    splashLogo = Image.asset('assets/splashCharacter.jpg');
    Timer(
        Duration(milliseconds: 2000),
            () => Navigator.pushNamed(context, '/menu'),
    );
  }
  
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    precacheImage(splashLogo!.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  '𝙚𝙯𝙁𝙞𝙩',
                  style: TextStyle(
                      fontSize: 60
                  )
              ),
              Container(
                width: 240,
                height: 240,
                child: Image(image: splashLogo!.image, fit: BoxFit.fill),
              ),
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
