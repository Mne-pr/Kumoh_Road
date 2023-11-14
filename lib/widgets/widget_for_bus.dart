import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 차피 하나만 하면 되므로 수정 가능성 낮음
class BusStopBox extends StatelessWidget {
  final String mainText;
  final String subText;
  final int numOfBus;
  final int id;

  BusStopBox({this.mainText="", this.subText="", this.id=0, this.numOfBus=0, super.key});

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

  const BusScheduleBox({this.mainText="", this.subText="", this.num=0, this.arriveText="", super.key});

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


// 진짜 임시임!!!!!! 시연용
class temp extends StatefulWidget {
  final BusStopBox busStop;

  const temp({required this.busStop, super.key});

  @override
  State<temp> createState() => _tempState();
}

class _tempState extends State<temp> {

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i=0; i < widget.busStop.numOfBus; i++) {
      switch (widget.busStop.mainText) {
        case "구미역":
          children.add(BusScheduleBox(mainText: '구미역 -> 금오공대종점',
              subText: '(비산동행정복지센터건너 - 비산동행정복지센터앞)',
              num: 190,
              arriveText: '5분 후 도착예정'));
          break;
        case "농협":
          children.add(BusScheduleBox(mainText: '농협 -> 금오공대종점',
              subText: '(비산동행정복지센터건너 - 비산동행정복지센터앞)',
              num: 195,
              arriveText: '5분 후 도착예정'));
          break;
        case "금오공대종점":
          children.add(BusScheduleBox(mainText: '금오공대종점 -> 구미역',
              subText: '(비산동행정복지센터건너 - 비산동행정복지센터앞)',
              num: 57,
              arriveText: '5분 후 도착예정'));
          break;
        case "금오공대입구(옥계중학교방면)":
          children.add(BusScheduleBox(mainText: '금오공대입구(옥계중학교방면) -> 구미역',
              subText: '(비산동행정복지센터건너 - 비산동행정복지센터앞)',
              num: 21,
              arriveText: '5분 후 도착예정'));
          break;
        default:
          SizedBox(height: 0);
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: Column(children: children,),
      ),
    );
  }
}