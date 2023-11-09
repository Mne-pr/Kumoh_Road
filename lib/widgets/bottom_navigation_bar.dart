import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/user_info_screen.dart';
/**
 * 여러 화면에서 편하게 하단 네비게이션바를 구현하도록 한다.
 * 화면을 추가로 구현할때마다 Navigator.push 해주어야함.
 */
class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final BuildContext context;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _onItemTapped(int index) {
      if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserInfoScreen()),
        );
      }
      // 본인 화면 만들때마다 추가할 것
    }
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: _onItemTapped,
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
    );
  }
}
