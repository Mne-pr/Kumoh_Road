// 버스정류장
import 'package:cloud_firestore/cloud_firestore.dart';

class BusSt{
  final String mainText;
  final String subText;
  final String code;
  final int id;

  BusSt({this.mainText="", this.subText="",this.code="", this.id=0});
}

// 버스
class Bus{
  int arrprevstationcnt;  // 남은 정류장 수
  int arrtime;            // 도착예상시간(초)
  final String nodeid;    // 정류소 ID
  final String nodenm;    // 정류소명
  final String routeid;   // 노선 ID  - 노선 위치
  final String routeno;   // 노선 번호 - 버스 번호
  final String routetp;   // 노선 유형
  final String vehicletp; // 자량 유형
  final String code;      // 버스 코드 - 고유 번호

  //final String direction;    // 가는 방향 - 구미역, 금오공대

  Bus({
    required this.arrprevstationcnt,
    required this.arrtime,
    required this.nodeid,
    required this.nodenm,
    required this.routeid,
    required this.routeno,
    required this.routetp,
    required this.vehicletp,
    required this.code,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this,other)) return true;

    return other is Bus && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      arrprevstationcnt: json['arrprevstationcnt'],
      arrtime:           json['arrtime'],
      nodeid:            json['nodeid'],
      nodenm:            json['nodenm'],
      routeid:           json['routeid'],
      routeno:           json['routeno'].toString(),
      routetp:           json['routetp'],
      vehicletp:         json['vehicletp'],
      code:           '${json['nodeid']}-${json['routeno']}-${json['routeid']}',
    );
  }
}

// 버스리스트 객체
class BusList {
  final List<Bus> buses;
  BusList({required this.buses});


  List<Map<String, dynamic>> getArrayFormat() {
    List<Map<String, dynamic>> target = [];

    for (Bus bus in buses) {
      target.add({
        'arrprevstationcnt': bus.arrprevstationcnt, // 남은 정류장 수
        'arrtime':           bus.arrtime,           // 도착예상시간(초)
        'nodeid':            bus.nodeid,            // 정류소 ID
        'nodenm':            bus.nodenm,            // 정류소명
        'routeid':           bus.routeid,           // 노선 ID
        'routeno':           bus.routeno,           // 노선번호 - 버스번호
        'routetp':           bus.routetp,           // 노선유형
        'vehicletp':         bus.vehicletp,         // 자량유형
        'code':              bus.code,              // 고유문자
      });
    }

    return target;
  }

  factory BusList.fromJson(final json) {
    List<Bus> buslist = [];

    try {
      var body = json['response']['body'];
      if (body == null) { throw Exception('Body is null'); }

      var totalCount = body['totalCount'];
      if (totalCount == 0) { throw Exception('No buses available'); }

      var items = body['items']['item'];
      if (items is List) {
        // item이 리스트일 경우
        buslist = items.map((i) => Bus.fromJson(i)).toList();
      } else {
        // item이 단일 객체일 경우
        buslist.add(Bus.fromJson(items));
      }

      buslist.sort((bus1, bus2) => bus1.arrtime.compareTo(bus2.arrtime));

    } catch(e) {
      print('BusList.fromJson error(ignore if error is []): ${e.toString()}');
      buslist = [];
    }

    return BusList(buses: buslist);
  }

  factory BusList.fromDocument(DocumentSnapshot doc){
    List<Map<String,dynamic>> tempBusList = [];
    List<Bus> buslist = [];
    List<dynamic> field;

    if (doc.exists) {
      field = doc.get('busList');
      for (var busInfo in field) { tempBusList.add(busInfo);}

      try {
        buslist = tempBusList.map((bus) => Bus.fromJson(bus)).toList();
        buslist.sort((bus1, bus2) => bus1.arrtime.compareTo(bus2.arrtime));
      } catch(e) { print('Buslist.fromDocument error: ${e.toString()}'); buslist=[];};
    }

    return BusList(buses: buslist);
  }
}