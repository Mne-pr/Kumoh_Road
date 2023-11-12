import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kumoh_road/widgets/bottom_scrollable_widget.dart';
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

  final gumiStationMark = NInfoWindow.onMap(id: "구미역", position: NLatLng(36.12827222, 128.3310162), text: "구미역");
  final busStop1 = NMarker(id: "구미역(버스정류장)", position: NLatLng(36.12963461, 128.3293215),);
  final busStop1Info = BusStopBox('구미역', '경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', 12321, 3);
  final busStop2 = NMarker(id: "농협(버스정류장)", position: NLatLng(36.12802335, 128.3331997),);
  final busStop2Info = BusStopBox('농협', '경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', 12321, 4);

  @override
  Widget build(BuildContext context) {
    const gumiStationPos = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
    final bottomScrollWidget = BottomScrollableWidget(busStop: currentBusStop,key: UniqueKey(),);
    final busStop1Window = NInfoWindow.onMarker(id: busStop1.info.id, text: busStop1Info.mainText);
    final busStop2Window = NInfoWindow.onMarker(id: busStop2.info.id, text: busStop2Info.mainText);


    void updateBusStop(final inpBusStop){ setState(() { currentBusStop = inpBusStop; }); }

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
              con.addOverlayAll({busStop1, busStop2, gumiStationMark});
              busStop1.setOnTapListener((overlay) async {
                updateBusStop(busStop1Info);
                busStop1.openInfoWindow(busStop1Window);
                busStop2Window.close();
              });
              busStop2.setOnTapListener((overlay) {
                updateBusStop(busStop2Info);
                busStop2.openInfoWindow(busStop2Window);
                busStop1Window.close();
              });
            },
          ),

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
