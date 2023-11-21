import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kumoh_road/providers/bus_station_info.dart';
import 'package:kumoh_road/screens/loading_screen.dart';
import 'package:kumoh_road/widgets/outline_circle_button.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;

class BusInfoScreen extends StatefulWidget {
  const BusInfoScreen({super.key});

  @override
  State<BusInfoScreen> createState() => _BusInfoScreenState();
}

class _BusInfoScreenState extends State<BusInfoScreen> with TickerProviderStateMixin {

  // api 호출
  final apiAddr = 'http://apis.data.go.kr/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList';
  final serKey = 'ZjwvGSfmMbf8POt80DhkPTIG41icas1V0hWkj4cp5RTi1Ruyy2LCU02TN8EJKg0mXS9g2O8B%2BGE6ZLs8VUuo4w%3D%3D';

  final busStopMarks = [
    NMarker(position: NLatLng(36.12963461, 128.3293215), id: "구미역"),
    NMarker(position: NLatLng(36.12802335, 128.3331997), id: "농협"),
    NMarker(position: NLatLng(36.14317057, 128.3943957), id: "금오공대종점"),
    NMarker(position: NLatLng(36.13948442, 128.3967393), id: "금오공대입구(옥계중학교방면)")
  ];
  final busStopInfos = [
    BusSt(code:"GMB80", id:10080,subText:'경상북도 구미시 구미중앙로 70',  mainText:'구미역'),
    BusSt(code:"GMB167",id:10167,subText:'경상북도 구미시 원평동 1008-40',mainText:'농협'),
    BusSt(code:"GMB132",id:10132,subText:'경상북도 구미시 거의동 550',    mainText:'금오공대종점'),
    BusSt(code:"GMB131",id:10131,subText:'경상북도 구미시 거의동 589-8',  mainText:'금오공대입구(옥계중학교방면)')
  ];
  late final busStopW;

  // 상태 저장하기 위한 변수
  late NaverMapController con;
  late int curBusStop = 0;  int numOfBus = 0;
  late List<OutlineCircleButton> buttons;
  late int curButton = 2;
  late List<Bus> busList = [];


  // 버스정류장 담당 애니메이션
  late AnimationController busStAnicon;
  late CurvedAnimation busStCurveAni;
  late Animation<double> busStAni;

  // 버스리스트 담당 애니메이션
  late Animation<double> busListAni;

  // 두 지역(구미역, 금오공대)에 대한 화면 포지션 정의
  static const gumiPos  = NCameraPosition(target: NLatLng(36.12745222, 128.3310162), zoom: 14.0, bearing: 0, tilt: 0);
  static const gumiSPos = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
  static const kumohPos = NCameraPosition(target: NLatLng(36.14132749, 128.3955675), zoom: 15.5, bearing: 0, tilt: 0);
  static const kumohSPos= NCameraPosition(target: NLatLng(36.14132749, 128.3955675), zoom: 15.5, bearing: 0, tilt: 0);

  bool isInfoOpen = true;
  bool isLocationChanged = false;

  @override
  void initState() {
    super.initState();

    final gumiMCamera  = NCameraUpdate.scrollAndZoomTo(target: gumiPos.target,  zoom: 15.5);
    final gumiSCamera  = NCameraUpdate.scrollAndZoomTo(target: gumiPos.target,  zoom: 15.5);
    final kumohMCamera = NCameraUpdate.scrollAndZoomTo(target: kumohPos.target, zoom: 15.5);
    final kumohSCamera = NCameraUpdate.scrollAndZoomTo(target: kumohPos.target, zoom: 15.5);

    // [정류장-미완, 구미역, 금오공대]
    buttons = [
      OutlineCircleButton(
        child: Icon(Icons.directions_bus_filled_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
        foregroundColor: Color(0xff05d686),borderColor: Colors.white,
        onTap: () async {
          setState(() { curButton = 0; isLocationChanged = true; });
          gumiMCamera.setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 500));
          await con.updateCamera(gumiMCamera);
          busStopMarks[0].performClick();
          setState(() { isLocationChanged = false; });
        }
      ),
      OutlineCircleButton( // 금오공대 -> 구미역
        child: Icon(Icons.directions_bus_filled_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
        foregroundColor: Color(0xff05d686), borderColor: Colors.white,
        onTap: () async {
          gumiMCamera.setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 500));
          await con.updateCamera(gumiMCamera);
          setState(() { curButton = 2; isLocationChanged = true; });
          busStopMarks[0].performClick();
          setState(() { isLocationChanged = false; });
        }
      ),
      OutlineCircleButton( // 구미역 -> 금오공대
        child: Icon(Icons.school_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
        foregroundColor: Color(0xff05d686),borderColor: Colors.white,
        onTap: () async {
          kumohMCamera.setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 500));
          await con.updateCamera(kumohMCamera);
          setState(() { curButton = 1; isLocationChanged = true; });
          busStopMarks[2].performClick();
          setState(() { isLocationChanged = false; });
        },
      )
    ];

    busStopW = [
      NInfoWindow.onMarker(id: busStopMarks[0].info.id, text: busStopInfos[0].mainText),
      NInfoWindow.onMarker(id: busStopMarks[1].info.id, text: busStopInfos[1].mainText),
      NInfoWindow.onMarker(id: busStopMarks[2].info.id, text: busStopInfos[2].mainText),
      NInfoWindow.onMarker(id: busStopMarks[3].info.id, text: busStopInfos[3].mainText),
    ];

    busStAnicon = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    busStCurveAni = CurvedAnimation(parent: busStAnicon, curve: Curves.easeInOutExpo);
    busStAni = Tween(begin: 0.0, end: 0.0).animate(busStCurveAni)
      ..addListener(() { setState(() {}); }); // 애니메이션 값이 변할 때마다 위젯을 다시 빌드.

    busListAni = Tween(begin: 0.0, end: 0.0).animate(busStCurveAni)
      ..addListener(() { setState(() {}); });

  }

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height * 0.78;
    busStAni = Tween(begin: 0.0, end: screenHeight).animate(busStCurveAni)
      ..addListener(() {setState(() {});});

    busListAni = Tween(begin: -MediaQuery.of(context).size.height / 2, end: 0.0).animate(busStCurveAni)
      ..addListener(() {setState(() {});});

    // 정류장의 정보 가져오는 함수
    Future<BusApiRes> fetchBusInfo(final nodeId) async {
      try{
        final res = await http.get(Uri.parse('${apiAddr}?serviceKey=${serKey}&_type=json&cityCode=37050&nodeId=${nodeId}'));
        if (res.statusCode == 200){ return BusApiRes.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));}
        else { throw Exception('Failed to load buses info');}
      } catch(e) {return BusApiRes.fromJson({});}
    }

    // 버스정류장 정보를 클릭할 때 이벤트 처리
    Future<void> busStationBoxClick() async {
      if (busStAnicon.isDismissed) {
        BusApiRes res = await fetchBusInfo(busStopInfos[curBusStop].code);
        setState(() { busList = res.buses; isInfoOpen = true; numOfBus = res.buses.length; });

        busStAnicon.forward();
      }
      else if (busStAnicon.isCompleted) {
        setState(() {isInfoOpen = false;});

        busStAnicon.reverse();
      }
    }

    // 버스정류장의 정보 알아오기
    Future<void> updateBusStop(int busStop) async {
      if (isInfoOpen == true || isLocationChanged == true) {
        BusApiRes res = await fetchBusInfo(busStopInfos[busStop].code);
        setState(() { busList = res.buses; });
      }

      for (int i = 0; i < 4; i++){
        if (busStop != i) {
          try { busStopW[i].close();} catch (e) {}
        }
      }
      setState(() { numOfBus = busList.length; curBusStop = busStop; });
    }

    Future<void> updateBusListBox() async {
      BusApiRes res = await fetchBusInfo(busStopInfos[curBusStop].code);
      setState(() { busList = res.buses; numOfBus = res.buses.length; });
    }

    return Scaffold(

      // 1. 버튼과 지도, 하단바 겹쳐 표시하기 위해 Stack 사용함
      body: SafeArea(
        child: Stack(
          children: [
            // 1.1 네이버맵을 가장 아래쪽(z)에 배치
            NaverMap(
              // 1.1.1 맵 초기화 옵션 지정
              options: const NaverMapViewOptions(
                minZoom: 12, maxZoom: 18, pickTolerance: 8, locale: Locale('kr'), mapType: NMapType.basic, liteModeEnable: true,
                initialCameraPosition: gumiPos, activeLayerGroups: [NLayerGroup.building, NLayerGroup.mountain, NLayerGroup.transit],
                rotationGesturesEnable: false, scrollGesturesEnable: false, tiltGesturesEnable: false, stopGesturesEnable: false, scaleBarEnable: false, logoClickEnable: false,
              ),
              // 1.1.2맵과 관련된 로직 정의
              onMapReady: (NaverMapController controller) async {
                // 1.1.2.1 맵 컨트롤러 등록
                con = controller;
                // 1.1.2.2 각 마커를 클릭했을 때의 이벤트 지정
                for (int i = 0; i < 4; i++){
                  con.addOverlay(busStopMarks[i]);
                  busStopMarks[i].setOnTapListener((overlay) async { await updateBusStop(i); busStopMarks[i].openInfoWindow(busStopW[i]);});
                }
                // 1.1.2.3 구미역 버튼 클릭
                busStopMarks[0].performClick();
              },
            ),

            // 1.2 위치 지정하여 버튼 배치. SizeBox를 사용하기 위해 Column 사용함
            Positioned(
              top: MediaQuery.of(context).size.width * 0.05 + busStAni.value / 6,
              left: MediaQuery.of(context).size.width * 0.05,
              child: buttons[curButton],
            ),

            // 1.3 버스 리스트위젯
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.78, left: 0, right: 0,
              child: BusListWidget(
                animation: busStAni,
                busList: busList,
                onRefresh: updateBusListBox,
                onScrollToTop: busStationBoxClick,
              ),
            ),

            // 1.4 선택한 버스정류장에 대한 정보 표시하는 창 배치
            Positioned(
              bottom: busStAni.value,
              left: 0, right: 0,
              height: MediaQuery.of(context).size.height * 0.125,
              child: SubWidget(onClick: busStationBoxClick, busStation: busStopInfos[curBusStop], numOfBus: numOfBus,),
            ),

            // 1.5 로딩화면
            LoadingScreen(miliTime: 1000,),
          ],
        ),
      ),

      // 2. 어플 공통의 네비게이션 바 배치
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 2,),
    );
  }

  @override
  void dispose() {
    busStAnicon.dispose();
    super.dispose();
  }
}
