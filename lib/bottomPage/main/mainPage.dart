import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_detection_app/utils/toast.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<MainPage> {
  var test = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  Image? mainImage;
  Image? profile;
  bool isImage = false;
  bool registered = false;

  @override
  void initState() {
    super.initState();
    mainImage = Image.asset('assets/mainCard.jpg');
    profile = Image.asset('assets/manWinter.jpg');
    setState(() {
      isImage = true;
    });
  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    precacheImage(mainImage!.image, context);
    precacheImage(profile!.image, context);
  }

  List<Widget> someItems() {
    List<List<String>> ment = [
      ['기구가 없어도 괜찮아!', '윗몸일으키기, 스쿼트'],
      ['원하는데로 움직여봐', '내가 하고싶은데로'],
      ['상쾌한 공기 어때?', '사랑하는 연인과 함께'],
      ['게임말고 달리기시합!', '게임보다 3000만큼 재밌어'],
      ['보기에는 쉬워보이지?', '먼저 쓰러지면 꿀밤']
    ];

    return List.generate(5, (index) {
      return InkWell(
        onTap: () => Navigator.pushNamed(context, '/content'),
        child: Container(
          child: Card(
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    width: 200,
                    child: Image.asset(
                        'assets/exercise${index+1}.jpg',
                        fit: BoxFit.fill
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 15, top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ment[index][0],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87
                            ),
                          ),
                          Text(
                            ment[index][1],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black54
                            ),
                          ),
                        ],
                      )
                  ),
                  Container(
                    height: 150,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Color(0xFF0E3311).withOpacity(0.3),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black,
                              Colors.white,
                              Colors.white,
                            ]
                        )
                    ),
                  ),
                ],
              )
          ),
        ),
      );
    });
  }

  void addUser() {
    setState(() => registered = !registered);
    showToast('서비스가 오픈되지 않았습니다.');
  }


  Widget profileText(String str) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        str,
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget profileCard() {
    return Container(
      child: Card(
        color: Color(0xfffdf9f6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 300,
                    child: Image(
                        image: profile!.image,
                        fit: BoxFit.fitHeight
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.only(left: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        profileText('키 : 180cm'),
                        profileText('몸무게 : 75kg'),
                        profileText('체지방 : 10%'),
                        profileText('근골격량 : 30%'),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }

  Widget mainCard() {
    return Container(
      child: Stack(
        children: [
          Container(
            height: 300,
            child: Image(
                image: mainImage!.image,
                fit: BoxFit.fitHeight
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(top: 70),
            child: Text(
              '사용자를 등록해주세요.',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.only(top: 10),
          child: Text(
              '𝙚𝙯𝙁𝙞𝙩',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.indigo
              )
          ),
        ),
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          // alignment: Alignment.topCenter,
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: InkWell(
                  onTap: () => addUser(),
                  child: registered ? profileCard() : mainCard(),
                ),
              ),
              SizedBox(
                height: 150,
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: someItems(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
