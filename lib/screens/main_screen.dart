import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/user_info_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      'icon': 'assets/images/school_logo(24x24).png',
      'title': '학교 홈페이지',
      'color': Colors.green,
    },
    {
      'icon': 'assets/images/webmail_logo(24x24).png',
      'title': '웹 메일',
      'color': Colors.blue,
    },
    {
      'icon': 'assets/images/e-class_logo(24x24).png',
      'title': '강의지원시스템',
      'color': Colors.yellow,
    },
    {
      'icon': 'assets/images/github_logo(24x24).png',
      'title': '깃 허브',
      'color': Colors.brown,
    },
    {
      'icon': 'assets/images/weather_logo(24x24).png',
      'title': '날씨 정보',
      'color': Colors.red,
    },
    {
      'icon': 'assets/images/gpt_logo(24x24).png',
      'title': 'AI Chat',
      'color': Colors.blueGrey,
    },
  ];
  MainScreen({super.key});
  void _launchURL(String pageUrl) async {
    final url = Uri.parse(pageUrl);
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    } throw 'Could not launch $url';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.5 / 1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _customButton(
            icon: items[index]['icon'],
            title: items[index]['title'],
            color: items[index]['color'],
            onTap: () {
              switch (items[index]['title']) {
                case '학교 홈페이지':
                  _launchURL('https://www.kumoh.ac.kr/ko/index.do');
                  break;
                case '웹 메일':
                  _launchURL('https://mail.kumoh.ac.kr/account/login.do');
                  break;
                case '강의지원시스템':
                  _launchURL('https://elearning.kumoh.ac.kr/');
                  break;
                case '깃 허브':
                  _launchURL('https://github.com/joon6093/Kumoh_Road');
                  break;
                case '날씨 정보':
                  Navigator.pushNamed(context, '/weather_info_screen');
                  break;
                case 'AI Chat':
                  Navigator.pushNamed(context, '/gpt_screen');
                  break;
              // 기타 등등...
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: '택시',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: '버스',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike),
            label: '자전거',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '내 정보',
          ),
        ],
      onTap: (index) {
          if (index == 4) { // Check if the "내 정보" item is selected (index 4)
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoScreen()));
          }
        },
      ),
    );
  }
  Widget _customButton({
    required String icon,
    required String title,
    required Color color,
    required void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: const Alignment(1.00, 0.00),
            end: const Alignment(-1, 0),
            colors: [Colors.black.withOpacity(0.7), color],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Row(
          children: <Widget>[
            Image.asset(icon),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}