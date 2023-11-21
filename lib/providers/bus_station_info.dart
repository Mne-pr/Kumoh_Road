import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 버스정류장
class BusSt{
  final String mainText;
  final String subText;
  final String code;
  final int id;

  BusSt({this.mainText="", this.subText="",this.code="", this.id=0});
}

// 버스
class Bus{
  final int arrprevstationcnt;
  final int arrtime;
  final String nodeid;
  final String nodenm;
  final String routeid;
  final String routeno;
  final String routetp;
  final String vehicletp;

  Bus({required this.arrprevstationcnt, required this.arrtime, required this.nodeid,
    required this.nodenm, required this.routeid, required this.routeno,
    required this.routetp,required this.vehicletp});

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      arrprevstationcnt: json['arrprevstationcnt'],
      arrtime: json['arrtime'],
      nodeid: json['nodeid'],
      nodenm: json['nodenm'],
      routeid: json['routeid'],
      routeno: json['routeno'].toString(),
      routetp: json['routetp'],
      vehicletp: json['vehicletp'],
    );
  }
}

// api로 버스정류장의 버스목록 읽어오기
class BusApiRes {
  final List<Bus> buses;

  BusApiRes({required this.buses});

  factory BusApiRes.fromJson(Map<String, dynamic> json) {
    List<Bus> busList;

    try{
      var item = json['response']['body']['items']['item'];
      List<dynamic> itemList = (item is List) ? item : [item];
      busList = itemList.map((i) => Bus.fromJson(i)).toList();
      busList.sort((a, b) => a.arrtime.compareTo(b.arrtime));
    } catch(e) {
      busList = [];
    }

    return BusApiRes(
      buses: busList
    );
  }
}


// 버스정류장 위젯
class SubWidget extends StatelessWidget {
  final VoidCallback onClick; // 클릭 이벤트를 위한 콜백
  final BusSt busStation;
  final int numOfBus;

  const SubWidget({Key? key, required this.onClick, required this.busStation, required this.numOfBus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [ // 위아래 그림자
              BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: Offset(0,-5)),
              BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: Offset(0, 5)),
            ]
        ),
        height: 100,
        child: Center(
            child: Text('버스 수 : ${numOfBus}, 정류장 이름 : ${busStation.mainText}')
        ),
      ),
    );
  }
}


class CustomAnimatedWidget extends StatelessWidget {
  final Animation<double> animation;
  final List<Bus> busList;

  CustomAnimatedWidget({
    Key? key,
    required this.animation,
    required this.busList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(bottom: animation.value), // 애니메이션 값에 따라 위치 조정
          height: MediaQuery.of(context).size.height / 2,
          color: Colors.white,
          child: ListView.builder(
              itemCount: busList.length,
              itemBuilder: (context, index) {
                Bus bus = busList[index];
                return ListTile(
                  title: Text("버스 : ${bus.routeno}"),
                  subtitle: Text("남은 시간 : ${bus.arrtime}"),
                );
              }
          ),
        );
      },
    );
  }
}