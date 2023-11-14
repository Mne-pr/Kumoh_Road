import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 스크롤 시 나타나는 부가효과 삭제위함
class NoGlowScrollBehavior extends ScrollBehavior {}

// 차피 하나만 하면 되므로 수정 가능성 낮음
class BusStopBox extends StatelessWidget {
  final String mainText;
  final String subText;
  final int numOfBus;
  final int id;

  BusStopBox(this.mainText, this.subText, this.id, this.numOfBus, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.location_on, color: Colors.blue, size: 25),
            SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    mainText,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14),
                  Text(
                    subText,
                    style: TextStyle(
                        fontSize: 12, color: CupertinoColors.inactiveGray),
                  ),
                  Text(
                    '$id',
                    style: TextStyle(
                        fontSize: 12, color: CupertinoColors.inactiveGray),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Divider(),
        SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 20),
            Text(
              '전체 노선 $numOfBus대',
              style:
                  TextStyle(fontSize: 13, color: CupertinoColors.inactiveGray),
            ),
          ],
        ),
        SizedBox(height: 5),

      ],
    );
  }
}

// 데이터를 배열로 받아야 해서 수정 가능성 높음
class BusScheduleBox extends StatelessWidget {
  final String mainText;
  final String subText;
  final String arriveText;
  final int num;

  const BusScheduleBox(this.mainText, this.subText, this.num, this.arriveText,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 5),
            Icon(Icons.directions_bus, color: Colors.blue, size: 25),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 2),
                  Text(
                    '$num | $mainText',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$subText',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 6),
                  // 남은 시간에 따라 색 바꾸는 것도 좋을듯?
                  Text(
                    '$arriveText',
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  SizedBox(height: 5)
                ],
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}


class BottomScrollableWidget extends StatefulWidget {
  final BusStopBox busStop;

  const BottomScrollableWidget({required this.busStop, super.key});

  @override
  State<BottomScrollableWidget> createState() => _BottomScrollableWidgetState();
}

class _BottomScrollableWidgetState extends State<BottomScrollableWidget> {
  final DraggableScrollableController con = DraggableScrollableController();

  void expandSheet([int speed = 100]) {
    con.animateTo(0.9,
        duration: Duration(milliseconds: speed), curve: Curves.easeOut);
  }

  void collapseSheet([int speed = 100]) {
    con.animateTo(0.20,
        duration: Duration(milliseconds: speed), curve: Curves.easeIn);
  }

  void autoExCo({int speed = 100}) {
    (con.size > 0.5) ? collapseSheet(speed) : expandSheet(speed);
  }

  @override
  Widget build(BuildContext context) {
    final busStop = widget.busStop;

    return DraggableScrollableSheet(
      controller: con,
      initialChildSize: 0.20,
      minChildSize: 0.20,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
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
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
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
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    controller: scrollController,
                    children: [
                      Column(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () { autoExCo();},
                              child: Container(
                                width: 150, height: 10,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                            ),
                          ),
                          busStop,
                        ],
                      ),
                    ],
                  ),
                ),

                Positioned.fill(
                  top: MediaQuery.of(context).size.height*0.15,
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    itemCount: 50,
                    itemBuilder: (context, index) {
                      return BusScheduleBox('금오공대종점 -> 구미역', '(비산동행정복지센터건너 - 비산동행정복지센터앞)', 21, '5분 후 도착예정');

                    },
                  ),
                )
              ],
            ),
          ),

        );
      },
    );
  }
}
