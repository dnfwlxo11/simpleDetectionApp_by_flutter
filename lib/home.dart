import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var test = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  var mainImage;
  bool isImage = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      mainImage = Image.asset('assets/mainCard.jpg');
      isImage = true;
    });
  }

  List<Widget> someItems() {
    return List.generate(test.length, (index) {
      return Container(
        child: Card(
            color: const Color(0xffe8e0fe),
            child: Column(
              children: [
                FlutterLogo(
                  size: 120,
                  textColor: const Color(0xffe8e0fe),
                ),
                Text('${index + 1}'),
              ],
            )
        ),
      );
    });
  }

  Widget mainCard() {
    return Card(
        child: Container(
          child: mainImage,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
        body: Center(
          child: Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              height: 450,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text('Good Day!',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 50
                        )
                    ),
                  ),
                  mainCard(),
                  isImage ? Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: someItems(),
                      )
                  ) : CircularProgressIndicator()
                ],
              ),
          ),
        ),
    );
  }
}
