import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/bus_station_model.dart';
import 'outline_circle_button.dart';


// 버스정류장 위젯
class BusStationWidget extends StatelessWidget {
  final VoidCallback onClick; // 클릭 이벤트를 위한 콜백
  final BusSt busStation;
  final int numOfBus;

  const BusStationWidget({Key? key, required this.onClick, required this.busStation, required this.numOfBus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) { if(details.delta.dy < 0) onClick();},
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

// 버스 목록 위젯
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
  Widget build(BuildContext context) {
    final numOfBus = widget.busList.length;

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
                    itemCount: (numOfBus == 0) ? 1 : numOfBus + 1,
                    itemBuilder: (context, index) {
                      if (numOfBus == 0) return Center(child: Text("버스가 없습니다",style: TextStyle(fontSize: 30)),); // 수정해야
                      if (index >= numOfBus) {return Column(children: [ Divider(), SizedBox(height: 80,)]);}
                      Bus bus = widget.busList[index];
                      // 남는 시간에 따른 색 분류
                      final urgentColor = ((bus.arrtime/60).toInt() >= 5) ? Colors.blue : Colors.red;
                      return Column(
                        children: [
                          Divider(thickness: 1.0, height: 1.0,),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
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
                                                Text('${bus.routeno} | 방향적어야함', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                                SizedBox(height: 10),
                                                Text('남은 정류장 : ${bus.arrprevstationcnt}', style: TextStyle(fontSize: 12, color: Colors.grey),),
                                                SizedBox(height: 6),
                                                Text('${(bus.arrtime/60).toInt()}분 ${bus.arrtime%60}초 후 도착', style: TextStyle(fontSize: 14, color: urgentColor),),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      barrierColor: Colors.transparent,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: MediaQuery.of(context).size.height * 0.78, // 모달의 높이
                                          child: Text("여기에 BusChatWidget 들어갈 것"),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.arrow_circle_up_outlined),
                              ),
                              SizedBox(width: 18,),
                            ],
                          ),
                        ],
                      );
                    }
                ),
              ),
            ),
            Positioned(
              right: MediaQuery.of(context).size.width * 0.05, bottom: MediaQuery.of(context).size.height * 0.8,
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

