import 'dart:convert';

import 'package:flutter/material.dart';

class Content extends StatefulWidget {
  const Content({Key? key}) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class ScreenArgment {
  final String imgPath;

  ScreenArgment(this.imgPath);
}

class _ContentState extends State<Content> {
  Image? contentImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contentImage = Image.asset('assets/exercise1.jpg');
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    precacheImage(contentImage!.image, context);
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text('컨텐츠'),
          backgroundColor: Color(0xff5293c9),
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  child: Image.asset(
                    args.toString(),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
                  child: Text(
                    '청산별곡',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    '살어리 살어리랏다 쳥산(靑山)애 살어리랏다\n'
                    '멀위랑 ᄃᆞ래랑 먹고 쳥산(靑山)애 살어리랏다\n'
                    '얄리 얄리 얄랑셩 얄라리 얄\n'
                    '우러라 우러라 새여 자고 니러 우러라 새\n'
                    '널라와 시름 한 나도 자고 니러 우리노\n'
                    '얄리 얄리 얄라셩 얄라리 얄\n'
                    '가던 새 가던 새 본다 믈아래 가던 새 본\n'
                    '잉무든 장글란 가지고 믈아래 가던 새 본\n'
                    '얄리 얄리 얄라셩 얄라리 얄\n'
                    '이링공 뎌링공 ᄒᆞ야 나즈란 디내와손\n'
                    '오리도 가리도 업슨 바므란 ᄯᅩ 엇디 호리\n'
                    '얄리 얄리 얄라셩 얄라리 얄\n'
                    '어듸라 더디던 돌코 누리라 마치던 돌\n'
                    '믜리도 괴리도 업시 마자셔 우니노\n'
                    '얄리 얄리 얄라셩 얄라리 얄\n'
                    '살어리 살어리랏다 바ᄅᆞ래 살어리랏\n'
                    'ᄂᆞᄆᆞ자기 구조개랑 먹고 바ᄅᆞ래 살어리랏\n'
                    '얄리 얄리 얄라셩 얄라리 얄\n'
                    '가다가 가다가 드로라 에졍지 가다가 드로\n'
                    '사ᄉᆞ미 지ᇝ대에 올아셔 ᄒᆡ금을 혀거를 드로\n'
                    '얄리 얄리 얄라셩 얄라리 얄\n'
                    '가다니 ᄇᆡ브론 도긔 설진 강수를 비조\n'
                    '조롱곳 누로기 ᄆᆡ와 잡ᄉᆞ와니 내 엇디 ᄒᆞ리잇\n'
                    '얄리 얄리 얄라셩 얄라리 얄라\n',
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
