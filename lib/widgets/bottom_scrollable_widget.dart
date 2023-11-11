import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoGlowScrollBehavior extends ScrollBehavior { }

class BottomScrollableWidget extends StatefulWidget {
  const BottomScrollableWidget({super.key});

  @override
  State<BottomScrollableWidget> createState() => _BottomScrollableWidgetState();
}

class _BottomScrollableWidgetState extends State<BottomScrollableWidget> {
  final DraggableScrollableController con = DraggableScrollableController();

  void expandSheet() {
    con.animateTo(0.9, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
  }

  void collapseSheet() {
    con.animateTo(0.05, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: con,
      initialChildSize: 0.035,
      minChildSize: 0.035,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0, // 그림자 흐림 정도
                spreadRadius: 5.0, // 그림자 범위
                offset: Offset(0.0, -5.0), // 그림자 위치
              ),
            ],
          ),
          child: ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(vertical: 7),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (con.size > 0.5) { collapseSheet(); }
                      else { expandSheet(); }
                    },
                    child: Container(
                      width: 150, height: 10,
                      margin: EdgeInsets.symmetric(vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // ListTile(title: Text('hello'),),
                // ListTile(title: Text('hi'),),

              ],
            ),
          ),
        );
      },
    );
  }
}
