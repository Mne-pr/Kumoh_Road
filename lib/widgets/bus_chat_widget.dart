import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BusChatWidget extends StatefulWidget {
  final VoidCallback onScrollToTop;
  const BusChatWidget({required this.onScrollToTop, super.key});

  @override
  State<BusChatWidget> createState() => _BusChatWidgetState();
}
class _BusChatWidgetState extends State<BusChatWidget> {
  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),

          height: MediaQuery.of(context).size.height / 2,
          child: RefreshIndicator(
            displacement: 100000, // 인디케이터 보이지 마라..
            onRefresh: () async { widget.onScrollToTop();},
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(title: Text('Item ${index + 1}'));
              },
            ),
          ),
        )
      ],
    );
  }
}
