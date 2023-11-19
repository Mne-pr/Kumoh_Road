import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 스크롤 시 나타나는 부가효과 삭제위함
class NoGlowScrollBehavior extends ScrollBehavior {}

class BottomScrollableWidget extends StatefulWidget {
  final Widget? topContent; // 상단 고정 콘텐츠
  final Widget restContent; // 하단 고정 콘텐츠
  final double bottomLength;
  final double topLength;

  const BottomScrollableWidget({
    this.topContent, required this.restContent,
    required this.bottomLength, required this.topLength,
    super.key
  });

  @override
  State<BottomScrollableWidget> createState() => _BottomScrollableWidgetState();
}

class _BottomScrollableWidgetState extends State<BottomScrollableWidget> {
  final DraggableScrollableController con = DraggableScrollableController();

  // 화면의 위치에 따라 늘리거나 줄이기 - 하단 바의 회색을 클릭하면 발동함
  void expandSheet({int time = 100})   { con.animateTo(widget.topLength, duration: Duration(milliseconds: time), curve: Curves.easeOut); }
  void collapseSheet({int time = 100}) { con.animateTo(widget.bottomLength, duration: Duration(milliseconds: time), curve: Curves.easeIn); }
  void autoExCo({int time = 100}){ (con.size > 0.5) ? collapseSheet(time: time) : expandSheet(time: time);}

  @override
  Widget build(BuildContext context) {

    return DraggableScrollableSheet(
      controller: con,
      initialChildSize: widget.bottomLength,
      minChildSize: widget.bottomLength,
      maxChildSize: widget.topLength,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          child: ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0),topRight: Radius.circular(50.0),),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, spreadRadius: 5.0, offset: Offset(0.0, -5.0),),],
                  ),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5), controller: scrollController,
                    children: [
                      Column(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () { autoExCo();},
                              child: Container(
                                width: 150, height: 10, margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                decoration: BoxDecoration( color: Colors.grey, borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),

                          // 여기 상단에 고정하고 싶은 것들
                          Stack(
                            children: [
                              widget.topContent ?? SizedBox.shrink(),
                              SizedBox(height: MediaQuery.of(context).size.height* widget.bottomLength),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Positioned.fill(
                  top: MediaQuery.of(context).size.height * (widget.bottomLength-0.02),
                  child: SingleChildScrollView( // 여기 나머지 것들
                      child: widget.restContent,
                  ),
                ),
              ],
            ),
          ),

        );
      },
    );
  }
}
