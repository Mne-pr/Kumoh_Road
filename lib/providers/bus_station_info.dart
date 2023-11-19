class Bus{
  final int arrprevstationcnt;
  final int arrtime;
  final String nodeid;
  final String nodenm;
  final String routeid;
  final int routeno;
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
      routeno: json['routeno'],
      routetp: json['routetp'],
      vehicletp: json['vehicletp'],
    );
  }
}

class BusApiRes {
  final List<Bus> buses;

  BusApiRes({required this.buses});

  factory BusApiRes.fromJson(Map<String, dynamic> json) {
    var item = json['response']['body']['items']['item'];
    List<dynamic> itemList = (item is List) ? item : [item];
    List<Bus> busList = itemList.map((i) => Bus.fromJson(i)).toList();

    return BusApiRes(
      buses: busList
    );
  }
}