import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/bus_info_screen.dart';
import '../screens/main_screen.dart';
import '../screens/user_info_screen.dart';
import '../screens/path_map_screen.dart';
/**
 * 여러 화면에서 편하게 하단 네비게이션바를 구현하도록 한다.
 * 화면을 추가로 구현할때마다 Navigator.push 해주어야함.
 */
class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _onItemTapped(int index) {
      if (selectedIndex == index) {
        // 이미 선택된 탭이면 아무것도 하지 않음
        return;
      }
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BusInfoScreen()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PathMapScreen())
          );
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserInfoScreen()),
          );
          break;
      // 다른 인덱스에 대한 네비게이션 로직 추가...
      }
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
