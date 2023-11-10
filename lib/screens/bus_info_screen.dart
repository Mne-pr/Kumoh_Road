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



  @override
  Widget build(BuildContext context) {

    // 특정 위치 설정 (예: 서울 시청)
    final NCameraPosition initialPosition = NCameraPosition(
      target: NLatLng(36.128769, 128.329622),
      zoom: 14,
    );

    return Scaffold(
      body: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
              target: NLatLng(36.128769, 128.329622), zoom: 10, bearing: 0, tilt: 0
          ),
          mapType: NMapType.basic,
          //liteModeEnable: true,
          activeLayerGroups: [NLayerGroup.building, NLayerGroup.mountain],
          pickTolerance: 8,
          rotationGesturesEnable: false,
          scrollGesturesEnable: false,
          tiltGesturesEnable: false,
          zoomGesturesEnable: false,
          stopGesturesEnable: false,
          locale: Locale('kr'),
        ),
        onMapReady: (controller){
          print("네이버 맵 로딩됨");
        },
      ),


      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}
