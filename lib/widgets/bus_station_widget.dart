import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/bus_station_model.dart';
import 'outline_circle_button.dart';


// 버스정류장 위젯
class BusStationWidget extends StatelessWidget {
  final VoidCallback onClick; // 클릭 이벤트를 위한 콜백
  final BusSt busStation;
  final bool isTop;

  const BusStationWidget({Key? key, required this.onClick, required this.busStation, required this.isTop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if(isTop == false && details.delta.dy < 0) {
          onClick();
        }
        if (isTop == true && details.delta.dy > 0) {
          onClick();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
          boxShadow: [ // 위아래 그림자
            BoxShadow(color: const Color(0xFF3F51B5).withOpacity(0.15), spreadRadius: 0, blurRadius: 10, offset: Offset(0,-5)),
          ],),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 20,),
                Icon(Icons.location_on, color: const Color(0xFF3F51B5), size: 25),
                SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${busStation.mainText}',
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
  final List<Bus> busList;
  final VoidCallback onScrollToTop;
  final Function(String) onCommentsCall;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const BusListWidget({
    required this.busList,
    required this.isLoading,
    required this.onScrollToTop,
    required this.onCommentsCall,
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
    setState(() { isRefreshing = widget.isLoading;});
    final numOfBus = widget.busList.length;

    if (isRefreshing) {
      return Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border( top: BorderSide(width: 0.5, color: const Color(0xFF3F51B5).withOpacity(0.2),),),
        ),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Center(child: CircularProgressIndicator(),),
          ),
        ),
      );
    }

    return Stack(
      children: [
        (numOfBus > 0)
        ? Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 2.0, color: const Color(0xFF3F51B5).withOpacity(0.2),),
              bottom: BorderSide(width: 0.5, color: const Color(0xFF3F51B5).withOpacity(0.2),),
            ),
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height / 2,
          child: RefreshIndicator(
            color: Colors.white10,
            displacement: 100000, // 인디케이터 보이지 마라..
            onRefresh: () async { widget.onScrollToTop();},
            child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: scrollcon,
                itemCount: (numOfBus == 0) ? 1 : numOfBus + 1,
                itemBuilder: (context, index) {
                  if (index >= numOfBus) {return Column(children: [ Divider(), SizedBox(height: 85,)]);}
                  Bus bus = widget.busList[index];
                  // 남는 시간에 따른 색 분류
                  final urgentColor = ((bus.arrtime/60).toInt() >= 5) ? const Color(0xFF3F51B5) : Colors.red;
                  final busColor = (bus.routetp == '일반버스') ? Color(0xff05d686) : Colors.purple;
                  return Column(
                    children: [
                      (index == 0) ? SizedBox(width: 0,) : Divider(thickness: 1.0, height: 1.0,),
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
                                      Icon(Icons.directions_bus, color: busColor, size: 25),
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
                            onPressed: () { widget.onCommentsCall(bus.code);},
                            icon: Icon(Icons.arrow_circle_up_outlined),
                            color: const Color(0xFF3F51B5),
                          ),
                          SizedBox(width: 18,),
                        ],
                      ),
                    ],
                  );
                }
            ),
          ),
        )
        : Container(
          decoration: BoxDecoration(color: Colors.white,),
          height: MediaQuery.of(context).size.height / 2,
          child: Center(child: Text("버스가 없습니다",style: TextStyle(fontSize: 30))),
        ),

        Positioned(
          right: MediaQuery.of(context).size.width * 0.05, bottom: MediaQuery.of(context).size.height * 0.03,
          child: OutlineCircleButton(
            child: Icon(Icons.refresh, color: Colors.white,), radius: 50.0, borderSize: 0.5,
            foregroundColor: isRefreshing ? Colors.transparent : const Color(0xFF3F51B5), borderColor: Colors.white,
            onTap: () async {
              await widget.onRefresh();
            },),
        ),

      ],
    );

  }

  @override
  void dispose() {
    scrollcon.dispose();
    super.dispose();
  }
}

