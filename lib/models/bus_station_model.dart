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
  final int arrprevstationcnt; // 남은 정류장 수
  final int arrtime;           // 도착예상시간(초)
  final String nodeid;         // 정류소 ID
  final String nodenm;         // 정류소명
  final String routeid;        // 노선 ID
  final String routeno;        // 노선번호 - 버스번호
  final String routetp;        // 노선유형
  final String vehicletp;      // 자량유형
  String encyptedname;   // 암호화된 이름

  Bus({required this.arrprevstationcnt, required this.arrtime, required this.nodeid,
    required this.nodenm, required this.routeid, required this.routeno,
    required this.routetp,required this.vehicletp, this.encyptedname=''});

  setEncryptedName(String newName) {
    encyptedname = newName;
  }

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
    } catch(e) {busList = [];}

    return BusApiRes(buses: busList);
  }
}