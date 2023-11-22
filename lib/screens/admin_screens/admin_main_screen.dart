import 'package:flutter/material.dart';
import '../../widgets/admin_bottom_navigation_bar.dart';


class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);
  @override
  _AdminMainScreenState createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
        ],
      ),
      bottomNavigationBar: AdminCustomBottomNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}