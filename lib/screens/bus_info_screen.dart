import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/bottom_navigation_bar.dart';
// google_maps_flutter.dart

class BusInfoScreen extends StatefulWidget {
  const BusInfoScreen({super.key});

  @override
  State<BusInfoScreen> createState() => _BusInfoScreenState();
}

class _BusInfoScreenState extends State<BusInfoScreen> {

  //

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(



          bottomNavigationBar: const CustomBottomNavigationBar(
            selectedIndex: 2,
          ),
      ),
    );
  }
}
