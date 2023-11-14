import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kumoh_road/widgets/bottom_scrollable_widget.dart';
import 'package:kumoh_road/widgets/outline_circle_button.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// 네이버지도 이슈
// [import android.os.Bundle], [override fun onCreate..] : naver map api 이슈 해결위한 추가
// https://note11.dev/flutter_naver_map/start/initial_setting
// +ios 세팅 현재 불가능

class BusInfoScreen extends StatefulWidget {
  const BusInfoScreen({super.key});

  @override
  State<BusInfoScreen> createState() => _BusInfoScreenState();
}

class _BusInfoScreenState extends State<BusInfoScreen> {
  late NaverMapController con;
  late BusStopBox currentBusStop = busStop1Info;

  // final gumiTrainStationMark = NInfoWindow.onMap(id: "구미역", position: NLatLng(36.12827222, 128.3310162), text: "구미역");
  final busStop1 = NMarker(id: "구미역", position: NLatLng(36.12963461, 128.3293215),);
  final busStop1Info = BusStopBox('구미역', '경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', 12321, 5);
  final busStop2 = NMarker(id: "농협", position: NLatLng(36.12802335, 128.3331997),);
  final busStop2Info = BusStopBox('농협', '경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', 12321, 2);

  // final kumohBusStationMark = NInfoWindow.onMap(id: "금오공대", position: NLatLng(36.14132749, 128.3955675), text: "금오공대");
  final busStop3 = NMarker(id: "금오공대종점", position: NLatLng(36.14317057, 128.3943957),);
  final busStop3Info = BusStopBox('금오공대종점', '경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', 12321, 3);
  final busStop4 = NMarker(id: "금오공대입구(옥계중학교방면)", position: NLatLng(36.13948442, 128.3967393),);
  final busStop4Info = BusStopBox('금오공대입구(옥계중학교방면)', '경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', 12321, 4);

  @override
  Widget build(BuildContext context) {
    final bottomScrollWidget = BottomScrollableWidget(busStop: currentBusStop,key: UniqueKey(),);

    const gumiStationPos = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
    const kumohStationPos = NCameraPosition(target: NLatLng(36.14132749, 128.3955675), zoom: 15.5, bearing: 0, tilt: 0);
    final gumiStationCameraUpdate = NCameraUpdate.scrollAndZoomTo(target: gumiStationPos.target, zoom: 15.5);
    final kumohStationCameraUpdate = NCameraUpdate.scrollAndZoomTo(target: kumohStationPos.target, zoom: 15.5);

    final busStop1Window = NInfoWindow.onMarker(id: busStop1.info.id, text: busStop1Info.mainText);
    final busStop2Window = NInfoWindow.onMarker(id: busStop2.info.id, text: busStop2Info.mainText);
    final busStop3Window = NInfoWindow.onMarker(id: busStop3.info.id, text: busStop3Info.mainText);
    final busStop4Window = NInfoWindow.onMarker(id: busStop4.info.id, text: busStop4Info.mainText);
    void updateBusStop(final inpBusStop){
      setState(() { currentBusStop = inpBusStop; });
    }

    int isItGumiStation(NLatLng a,NLatLng b){
      print("${double.parse(a.latitude.toStringAsFixed(8)) - b.latitude}");
      if (double.parse(a.latitude.toStringAsFixed(8)) - b.latitude == 0.0) {print("0반환"); return 0;}
      else return 1;
    }
    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              minZoom: 12, maxZoom: 18, pickTolerance: 8, locale: Locale('kr'),
              mapType: NMapType.basic, liteModeEnable: true,
              initialCameraPosition: gumiStationPos,
              activeLayerGroups: [NLayerGroup.building, NLayerGroup.mountain, NLayerGroup.transit],
              // 줌 제스쳐만 허용
              rotationGesturesEnable: false, scrollGesturesEnable: false, tiltGesturesEnable: false, stopGesturesEnable: false,
              scaleBarEnable: false, logoClickEnable: false,
            ),
            onMapReady: (NaverMapController controller){
              con = controller;
              // 구미역 앞의 버스정류장 두 곳에 마커
              con.addOverlayAll({busStop1, busStop2, busStop3, busStop4});
              busStop1.setOnTapListener((overlay) async {
               updateBusStop(busStop1Info);
               busStop1.openInfoWindow(busStop1Window);
               busStop2Window.close(); busStop3Window.close(); busStop4Window.close();
              });
              busStop2.setOnTapListener((overlay) {
               updateBusStop(busStop2Info);
               busStop2.openInfoWindow(busStop2Window);
               busStop1Window.close(); busStop3Window.close(); busStop4Window.close();
              });
              busStop3.setOnTapListener((overlay) async {
                updateBusStop(busStop3Info);
                busStop3.openInfoWindow(busStop3Window);
                busStop1Window.close(); busStop2Window.close(); busStop4Window.close();
              });
              busStop4.setOnTapListener((overlay) {
                updateBusStop(busStop4Info);
                busStop4.openInfoWindow(busStop4Window);
                busStop1Window.close(); busStop2Window.close(); busStop3Window.close();
              });

              gumiStationCameraUpdate.setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 500));
              kumohStationCameraUpdate.setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 500));

              busStop1.performClick();
            },
          ),
          Column(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
              Row(children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                OutlineCircleButton(
                  child: Icon(Icons.ac_unit),
                  radius: 50.0,
                  borderSize: 0.5,
                  onTap: () async {
                    final curCameraPos = await con.getCameraPosition();
                    if (isItGumiStation(curCameraPos.target, gumiStationPos.target) == 1){
                      await con.updateCamera(gumiStationCameraUpdate);
                      busStop1.performClick();
                    }
                    else{
                      await con.updateCamera(kumohStationCameraUpdate);
                      busStop3.performClick();
                    }
                  },
                ),
              ],),
            ],),

          Align(
            alignment: Alignment.bottomCenter,
            child: bottomScrollWidget,
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}
