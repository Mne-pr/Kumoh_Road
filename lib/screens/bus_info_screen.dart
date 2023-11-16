import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kumoh_road/screens/loading_screen.dart';
import 'package:kumoh_road/widgets/bottom_scrollable_widget.dart';
import 'package:kumoh_road/widgets/outline_circle_button.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/widget_for_bus.dart';

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

  // 각각 정류장 관련 변수 - 배열로 할지 고민중
  final busStop1 = NMarker(position: NLatLng(36.12963461, 128.3293215), id: "구미역");
  final busStop2 = NMarker(position: NLatLng(36.12802335, 128.3331997), id: "농협");
  final busStop3 = NMarker(position: NLatLng(36.14317057, 128.3943957), id: "금오공대종점");
  final busStop4 = NMarker(position: NLatLng(36.13948442, 128.3967393), id: "금오공대입구(옥계중학교방면)");
  final busStop1Info = BusStopBox(subText:'경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', id:12321, numOfBus:13, mainText:'구미역');
  final busStop2Info = BusStopBox(subText:'경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', id:12321, numOfBus:4, mainText:'농협');
  final busStop3Info = BusStopBox(subText:'경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', id:12321, numOfBus:9, mainText:'금오공대종점');
  final busStop4Info = BusStopBox(subText:'경상북도 구미시 선산읍 선산대로 1408 (동부리 327-5)', id:12321, numOfBus:3, mainText:'금오공대입구(옥계중학교방면)');

  // 상태 저장하기 위한 변수
  late NaverMapController con;
  late BusStopBox currentBusStop = busStop1Info;
  late OutlineCircleButton trainBtn;
  late OutlineCircleButton schoolBtn;
  late OutlineCircleButton currentBtn = schoolBtn;

  bool isLoading = true;

  // 임시 변수
  late temp forBusList;
  
  @override
  Widget build(BuildContext context) {
    // 버스 정보 표시할 위젯
    final bottomScrollWidget = BottomScrollableWidget(
      topContent: currentBusStop,
      restContent: temp(busStop: currentBusStop ),
      bottomLength: 0.17,
      topLength: 0.9,
      key: UniqueKey(),
    );

    // 두 지역(구미역, 금오공대)에 대한 화면 포지션 정의
    const gumiStationPos =  NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
    const kumohStationPos = NCameraPosition(target: NLatLng(36.14132749, 128.3955675), zoom: 15.5, bearing: 0, tilt: 0);
    final gumiStationCameraUpdate =  NCameraUpdate.scrollAndZoomTo(target: gumiStationPos.target,  zoom: 15.5);
    final kumohStationCameraUpdate = NCameraUpdate.scrollAndZoomTo(target: kumohStationPos.target, zoom: 15.5);
    // 표시할 정류장은 4개 뿐이므로 정류장 정보 하드코딩 //배열로 합쳐버릴까
    final busStop1Window = NInfoWindow.onMarker(id: busStop1.info.id, text: busStop1Info.mainText);
    final busStop2Window = NInfoWindow.onMarker(id: busStop2.info.id, text: busStop2Info.mainText);
    final busStop3Window = NInfoWindow.onMarker(id: busStop3.info.id, text: busStop3Info.mainText);
    final busStop4Window = NInfoWindow.onMarker(id: busStop4.info.id, text: busStop4Info.mainText);

    // 위젯을 업데이트하는 함수. 이때 api 사용하여 버스정류장의 정보 알아올 것
    void updateBusStop(final inpBusStop){
      setState(() {
        currentBusStop = inpBusStop;
      });
    }

    // 구미역으로 이동하는 버튼
    trainBtn = OutlineCircleButton(
      child: Icon(Icons.train_outlined), radius: 50.0, borderSize: 0.5,
      onTap: () async {
        gumiStationCameraUpdate.setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 500));
        await con.updateCamera(gumiStationCameraUpdate);
        busStop1.performClick(); currentBtn = schoolBtn;
      }
    );

    // 금오공대로 이동하는 버튼
    schoolBtn = OutlineCircleButton(
      child: Icon(Icons.school_outlined), radius: 50.0, borderSize: 0.5,
      onTap: () async {
        kumohStationCameraUpdate.setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 500));
        await con.updateCamera(kumohStationCameraUpdate);
        busStop3.performClick(); currentBtn = trainBtn;
      },
    );

    return Scaffold(

      // 1. 버튼과 지도, 하단바 겹쳐 표시하기 위해 Stack 사용함
      body: SafeArea(
        child: Stack(
          children: [
            // 1.1 네이버맵을 가장 아래쪽(z)에 배치
            NaverMap(
              // 1.1.1 맵 초기화 옵션 지정
              options: const NaverMapViewOptions(
                minZoom: 12, maxZoom: 18, pickTolerance: 8, locale: Locale('kr'),
                mapType: NMapType.basic, liteModeEnable: true,
                initialCameraPosition: gumiStationPos,
                activeLayerGroups: [NLayerGroup.building, NLayerGroup.mountain, NLayerGroup.transit],
                rotationGesturesEnable: false, scrollGesturesEnable: false, tiltGesturesEnable: false, stopGesturesEnable: false,
                scaleBarEnable: false, logoClickEnable: false,
              ),

              // 1.1.2맵과 관련된 로직 정의
              onMapReady: (NaverMapController controller){
                // 1.1.2.1 맵 컨트롤러 등록
                con = controller;
                // 1.1.2.2 마커를 맵에 등록
                con.addOverlayAll({busStop1, busStop2, busStop3, busStop4,});
                // 1.1.2.3 각 마커를 클릭했을 때의 이벤트 지정
                busStop1.setOnTapListener((overlay) {
                  updateBusStop(busStop1Info); busStop1.openInfoWindow(busStop1Window);
                  busStop2Window.close(); busStop3Window.close(); busStop4Window.close();
                });
                busStop2.setOnTapListener((overlay) {
                  updateBusStop(busStop2Info); busStop2.openInfoWindow(busStop2Window);
                  busStop1Window.close(); busStop3Window.close(); busStop4Window.close();
                });
                busStop3.setOnTapListener((overlay) {
                  updateBusStop(busStop3Info); busStop3.openInfoWindow(busStop3Window);
                  busStop1Window.close(); busStop2Window.close(); busStop4Window.close();
                });
                busStop4.setOnTapListener((overlay) {
                  updateBusStop(busStop4Info); busStop4.openInfoWindow(busStop4Window);
                  busStop1Window.close(); busStop2Window.close(); busStop3Window.close();
                });
                busStop1.performClick();
              },

            ),
            // 1.2 위치 지정하여 버튼 배치. SizeBox를 사용하기 위해 Column 사용함
            Column(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
              Row(children: [SizedBox(width: MediaQuery.of(context).size.width * 0.05,),currentBtn,],),],
            ),
            // 1.3 선택한 버스정류장에 대한 정보 표시하는 창 배치
            bottomScrollWidget,
            LoadingScreen(miliTime: 500),
          ],
        ),
      ),

      // 2. 어플 공통의 네비게이션 바 배치
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 2,),
    );
  }
}
