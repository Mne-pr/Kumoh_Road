import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/main_screen_button_model.dart';
import '../utilities/url_launcher_util.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/main_screen_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int _selectedIndex = 0;
  final List<MainScreenButtonModel> items = [
    MainScreenButtonModel(
      icon: 'assets/images/school_logo(24x24).png',
      title: '학교 홈페이지',
      color: Colors.green,
      url: 'https://www.kumoh.ac.kr/ko/index.do',
    ),
    MainScreenButtonModel(
      icon: 'assets/images/webmail_logo(24x24).png',
      title: '웹 메일',
      color: Colors.blue,
      url: 'https://mail.kumoh.ac.kr/account/login.do',
    ),
    MainScreenButtonModel(
      icon: 'assets/images/e-class_logo(24x24).png',
      title: '강의지원시스템',
      color: Colors.yellow,
      url: 'https://elearning.kumoh.ac.kr/',
    ),
    MainScreenButtonModel(
      icon: 'assets/images/github_logo(24x24).png',
      title: '깃 허브',
      color: Colors.brown,
      url: 'https://github.com/joon6093/Kumoh_Road',
    ),
    MainScreenButtonModel(
      icon: 'assets/images/weather_logo(24x24).png',
      title: '날씨 정보',
      color: Colors.red,
      url: 'https://www.weather.com/',
    ),
    MainScreenButtonModel(
      icon: 'assets/images/gpt_logo(24x24).png',
      title: 'AI Chat',
      color: Colors.blueGrey,
      url: 'https://www.openai.com/',
    ),
  ];
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
          final item = items[index];
          return MainScreenButton(
            icon: item.icon,
            title: item.title,
            color: item.color,
            onTap: () {
              if (item.title == '날씨 정보') {
                Navigator.pushNamed(context, '/weather_info_screen');
              } else if (item.title == 'AI Chat') {
                Navigator.pushNamed(context, '/gpt_screen');
              } else {
                launchURL(item.url);
              }
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        context: context,
      ),
    );
  }
}