import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/taxi_screens/taxi_screen.dart';
import '../screens/bus_info_screens/bus_info_screen.dart';
import '../screens/main_screens/main_screen.dart';
import '../screens/user_info_screens/user_info_screen.dart';
import '../screens/bike_screens/path_map_screen.dart';
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
        return;
      }
      Widget nextPage;
      switch (index) {
        case 0:
          nextPage = const MainScreen();
          break;
        case 1:
          nextPage = const TaxiScreen();
          break;
        case 2:
          nextPage = const BusInfoScreen();
          break;
        case 3:
          nextPage = const PathMapScreen();
          break;
        case 4:
          nextPage = const UserInfoScreen();
          break;
        default:
          return;
      }
      Navigator.pushReplacement(
        context,
        CustomPageRouteBuilder(
          child: nextPage,
          currentIndex: selectedIndex,
          newIndex: index,
        ),
      );
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

class CustomPageRouteBuilder<T> extends PageRouteBuilder<T> {
  final Widget child;
  final int currentIndex;
  final int newIndex;

  CustomPageRouteBuilder({
    required this.child,
    required this.currentIndex,
    required this.newIndex,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      if (currentIndex < newIndex) {
        begin = const Offset(1.0, 0.0);
      } else {
        begin = const Offset(-1.0, 0.0);
      }
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

