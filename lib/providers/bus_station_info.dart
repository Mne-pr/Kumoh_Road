import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kumoh_road/widgets/outline_circle_button.dart';

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
    } catch(e) {busList = [];}

    return BusApiRes(buses: busList);
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
        child: Column(
          children: [
            SizedBox(height: 15,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 10,),
                Icon(Icons.location_on, color: Colors.blue, size: 25),
                SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${busStation.mainText} [ ${numOfBus} ]',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ), SizedBox(height: 14),
                      Text(
                        busStation.subText,
                        style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
                      ),
                      Text(
                        '${busStation.id}',
                        style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}


class BusListWidget extends StatefulWidget {
  final Animation<double> animation;
  final List<Bus> busList;
  final VoidCallback onScrollToTop;
  final Future<void> Function() onRefresh;

  const BusListWidget({
    required this.animation,
    required this.busList,
    required this.onScrollToTop,
    required this.onRefresh,
    super.key});

  @override
  State<BusListWidget> createState() => _BusListWidgetState();
}

class _BusListWidgetState extends State<BusListWidget> {
  late ScrollController scrollcon = ScrollController();
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: Offset(0,-5)),],
              ),
              margin: EdgeInsets.only(bottom: widget.animation.value), // 애니메이션 값에 따라 위치 조정
              height: MediaQuery.of(context).size.height / 2,
              child: RefreshIndicator(
                color: Colors.white10,
                displacement: 10000, // 인디케이터 보이지 마라..
                onRefresh: () async { widget.onScrollToTop();},
                child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: scrollcon,
                    itemCount: widget.busList.length,
                    itemBuilder: (context, index) {
                      Bus bus = widget.busList[index];
                      // 남는 시간에 따른 색 분류
                      final urgentColor = ((bus.arrtime/60).toInt() >= 5) ? Colors.blue : Colors.red;
                      return Column(
                        children: [
                          Divider(thickness: 1.0, height: 1.0,),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 8),
                                Icon(Icons.directions_bus, color: Colors.blue, size: 25),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 2),
                                      Text('${bus.routeno} | ${bus.arrprevstationcnt} 정류장 남음',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                      SizedBox(height: 10),
                                      Text('뭐적냐',style: TextStyle(fontSize: 12, color: Colors.grey),),
                                      SizedBox(height: 6),
                                      Text('${(bus.arrtime/60).toInt()}분 ${bus.arrtime%60}초 후 도착',style: TextStyle(fontSize: 14, color: urgentColor),),
                                    ],),),],),),],
                      );
                    }

                ),
              ),
            ),

            Positioned(
              right: 25, bottom: MediaQuery.of(context).size.height * 0.8,
              child: OutlineCircleButton(
                child: Icon(Icons.refresh, color: isRefreshing ? Colors.grey : Colors.white,), radius: 50.0, borderSize: 0.5,
                foregroundColor: isRefreshing ? Colors.transparent : Color(0xff05d686), borderColor: Colors.white,
                onTap: isRefreshing ? null : () async {
                  setState(() => isRefreshing = true);
                  await widget.onRefresh();
                  setState(() => isRefreshing = false);
                },),
            ),
          ],
        );
      },
    );

  }

  @override
  void dispose() {
    scrollcon.dispose();
    super.dispose();
  }
}


