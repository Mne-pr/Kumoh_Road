import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kumoh_road/models/main_screen_button_model.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/main_screen_button.dart';

class PathMapScreen extends StatefulWidget {
  const PathMapScreen({Key? key}) : super(key: key);

  @override
  _PathMapScreenState createState() => _PathMapScreenState();
}

class _PathMapScreenState extends State<PathMapScreen> {
  final List<MainScreenButtonModel> items = [
    MainScreenButtonModel(
      icon: 'assets/images/school_logo(24x24).png',
      title: '학교 홈페이지',
      color: Colors.green,
      url: 'https://www.kumoh.ac.kr/ko/index.do',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 3.5 / 1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return MainScreenButton(
            icon: item.icon,
            title: item.title,
            color: item.color,
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 3,
      ),
    );
  }
}
