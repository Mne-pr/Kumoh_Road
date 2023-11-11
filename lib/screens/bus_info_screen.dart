import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    // 시작위치 - 구미역
    const gumiStationPos = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);

    final gumiStationMark = NInfoWindow.onMap(id: "구미역", position: NLatLng(36.12827222, 128.3310162), text: "구미역");
    final busStop1 = NMarker(id: "구미역(버스정류장)", position: NLatLng(36.12963461, 128.3293215),);
    final busStop2 = NMarker(id: "농협(버스정류장)", position: NLatLng(36.12802335, 128.3331997),);

    //final busStop1Info = NInfoWindow.onMarker(id: busStop1.info.id, text: "구미역(버스정류장)");
    //final busStop2Info = NInfoWindow.onMarker(id: busStop2.info.id, text: "농협(버스정류장)");

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
              // 구미역 앞의 버스정류장 두 곳에 마커 달고, 설명 달음
              con.addOverlay(busStop1);
              con.addOverlay(busStop2);
              con.addOverlay(gumiStationMark);
            },
          ),

          Align(
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),

      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}
