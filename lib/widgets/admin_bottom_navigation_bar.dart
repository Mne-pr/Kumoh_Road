import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/admin_screens/admin_bus_chat_manage_screen.dart';
import 'package:kumoh_road/screens/admin_screens/admin_info_screen.dart';
import 'package:kumoh_road/screens/admin_screens/admin_main_screen.dart';

import '../screens/admin_screens/admin_user_manage_screen.dart';
/**
 * 여러 화면에서 편하게 *관리자를 위한* 하단 네비게이션바를 구현하도록 한다.
 * 화면을 추가로 구현할때마다 Navigator.push 해주어야함.
 */
class AdminCustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const AdminCustomBottomNavigationBar({
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
          nextPage = AdminMainScreen();
          break;
        case 2:
          nextPage = const AdminBusChatManageScreen();
        case 3:
          nextPage = const AdminUserManageScreen();
          break;
        case 4:
          nextPage = const AdminInfoScreen();
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
          label: '게시글 관리',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_bus),
          label: '댓글 관리',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt),
          label: '사용자 관리',
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

