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
  
  // 지도 컨트롤러
  late NaverMapController con;
  
  // 지도의 마크와 마크 위에 띄울 위젯
  final busStopMarks = [
    NMarker(position: NLatLng(36.12963461, 128.3293215), id: "구미역"),
    NMarker(position: NLatLng(36.12802335, 128.3331997), id: "농협"),
    NMarker(position: NLatLng(36.14317057, 128.3943957), id: "금오공대종점"),
    NMarker(position: NLatLng(36.13948442, 128.3967393), id: "금오공대입구(옥계중학교방면)")
  ];
  late final busStopW;
  
  // 버스정류장 정보와 그 상태들
  final busStopInfos = [
    BusSt(code:"GMB80", id:10080,subText:'경상북도 구미시 구미중앙로 70',  mainText:'구미역'),
    BusSt(code:"GMB167",id:10167,subText:'경상북도 구미시 원평동 1008-40',mainText:'농협'),
    BusSt(code:"GMB132",id:10132,subText:'경상북도 구미시 거의동 550',    mainText:'금오공대종점'),
    BusSt(code:"GMB131",id:10131,subText:'경상북도 구미시 거의동 589-8',  mainText:'금오공대입구(옥계중학교방면)')
  ];
  late int curBusStop = 0;
  late int numOfBus = 0;
  late List<Bus> busList = [];
  
  // 위치 이동 버튼과 상태
  late List<OutlineCircleButton> buttons;
  late int curButton = 2;

  // 버스정류장 담당 애니메이션
  late AnimationController busStAnicon = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
  late CurvedAnimation busStCurveAni =   CurvedAnimation(parent: busStAnicon, curve: Curves.easeInOutExpo);
  late Animation<double> busStAni =      Tween(begin: 0.0, end: 0.0).animate(busStCurveAni)..addListener(() { setState(() {}); });

  // 버스리스트 담당 애니메이션
  late Animation<double> busListAni =    Tween(begin: 0.0, end: 0.0).animate(busStCurveAni)..addListener(() { setState(() {}); });

  // 두 지역(구미역, 금오공대)에 대한 화면 포지션 정의
  static const gumiPos  = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
  static const gumiSPos = NCameraPosition(target: NLatLng(36.12727222, 128.3310162), zoom: 15.2, bearing: 0, tilt: 0);
  static const kumohPos = NCameraPosition(target: NLatLng(36.14132749, 128.3955675), zoom: 15.5, bearing: 0, tilt: 0);
  static const kumohSPos= NCameraPosition(target: NLatLng(36.13762749, 128.3955675), zoom: 14.0, bearing: 0, tilt: 0);
  
  // 지역을 이동할 때 사용하는 것
  final cameras = [
    NCameraUpdate.scrollAndZoomTo(target: gumiPos.target,   zoom: gumiPos.zoom),  // 구미역
    NCameraUpdate.scrollAndZoomTo(target: gumiSPos.target,  zoom: gumiSPos.zoom), // 구미역 축소
    NCameraUpdate.scrollAndZoomTo(target: kumohPos.target,  zoom: kumohPos.zoom), // 금오공대
    NCameraUpdate.scrollAndZoomTo(target: kumohSPos.target, zoom: kumohSPos.zoom) // 금오공대 축소
  ];

  @override
  void initState() {
    super.initState();

    // 반복문으로 줄일 수 있을 것 같음!! - 나중에
    NCameraAnimation btnFly = NCameraAnimation.fly;
    Duration btnDuration = Duration(milliseconds: 500);
    buttons = [
      OutlineCircleButton( // [정류장 -> 구미역 or 금오공대] - 미완
        child: Icon(Icons.directions_bus_filled_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
        foregroundColor: Color(0xff05d686),borderColor: Colors.white,
        onTap: () async {
          // setState(() { curButton = 0; });
          // gumiMCamera.setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 500));
          // await con.updateCamera(gumiMCamera);
          // busStopMarks[0].performClick();
        }
      ),
      OutlineCircleButton( // 금오공대 -> 구미역
        child: Icon(Icons.directions_bus_filled_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
        foregroundColor: Color(0xff05d686), borderColor: Colors.white,
        onTap: () async {
          if (busStAnicon.isDismissed){
            cameras[0].setAnimation(animation: btnFly, duration: btnDuration); con.updateCamera(cameras[0]);
          } else {
            cameras[1].setAnimation(animation: btnFly, duration: btnDuration); con.updateCamera(cameras[1]);
          }
          setState(() { curButton = 2; });
          await busStopMarks[0].performClick();
        }
      ),
      OutlineCircleButton( // 구미역 -> 금오공대
        child: Icon(Icons.school_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
        foregroundColor: Color(0xff05d686),borderColor: Colors.white,
        onTap: () async {
          if (busStAnicon.isDismissed){
            cameras[2].setAnimation(animation: btnFly, duration: btnDuration); con.updateCamera(cameras[2]);
          } else {
            cameras[3].setAnimation(animation: btnFly, duration: btnDuration); con.updateCamera(cameras[3]);
          }
          setState(() { curButton = 1; });
          await busStopMarks[2].performClick();
        },
      )
    ];

    busStopW = [
      NInfoWindow.onMarker(id: busStopMarks[0].info.id, text: busStopInfos[0].mainText),
      NInfoWindow.onMarker(id: busStopMarks[1].info.id, text: busStopInfos[1].mainText),
      NInfoWindow.onMarker(id: busStopMarks[2].info.id, text: busStopInfos[2].mainText),
      NInfoWindow.onMarker(id: busStopMarks[3].info.id, text: busStopInfos[3].mainText),
    ];

  }

  @override
  Widget build(BuildContext context) {

    // 기기의 화면 크기를 이용해 애니메이션 재설정
    double screenHeight = MediaQuery.of(context).size.height * 0.78;
    busStAni = Tween(begin: 0.0, end: screenHeight).animate(busStCurveAni)..addListener(() {setState(() {});});
    busListAni = Tween(begin: -MediaQuery.of(context).size.height / 2, end: 0.0).animate(busStCurveAni)..addListener(() {setState(() {});});

    // 정류장의 정보 가져오는 함수
    Future<BusApiRes> fetchBusInfo(final nodeId) async {
      try{
        final res = await http.get(Uri.parse('${apiAddr}?serviceKey=${serKey}&_type=json&cityCode=37050&nodeId=${nodeId}'));
        if (res.statusCode == 200){ return BusApiRes.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));}
        else { throw Exception('Failed to load buses info');}
      } catch(e) {return BusApiRes.fromJson({});}
    }

    // 정류장 정보 얻어와 리스트 저장하는 함수
    Future<void> updateBusListBox() async {
      BusApiRes res = await fetchBusInfo(busStopInfos[curBusStop].code);
      setState(() { busList = res.buses; numOfBus = res.buses.length; });
    }

    // 버스정류장의 정보 알아오기
    Future<void> updateBusStop(int busStop) async {
      setState(() { curBusStop = busStop; });
      await updateBusListBox();

      for (int i = 0; i < 4; i++){
        if (busStop != i) {
          try { busStopW[i].close();} catch (e) {}
        }
      }
    }

    // 버스정류장 정보를 클릭할 때 이벤트 처리
    Future<void> busStationBoxClick() async {
      if (busStAnicon.isDismissed) {
        cameras[(curBusStop==0 || curBusStop == 1) ? 1 : 3].setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 200));
        await con.updateCamera(cameras[(curBusStop==0 || curBusStop == 1) ? 1 : 3]);

        busStAnicon.forward();
      }
      else if (busStAnicon.isCompleted) {
        cameras[(curBusStop==0 || curBusStop == 1) ? 0 : 2].setAnimation(animation: NCameraAnimation.fly, duration: Duration(milliseconds: 200));
        await con.updateCamera(cameras[(curBusStop==0 || curBusStop == 1) ? 0 : 2]);

        busStAnicon.reverse();
      }
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

            // 1.2 위치 변경 버튼 위젯
            Positioned(
              top: MediaQuery.of(context).size.width * 0.05 + busStAni.value / 6,
              left: MediaQuery.of(context).size.width * 0.05,
              child: buttons[curButton],
            ),

            // 1.3 버스 리스트 위젯
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.78, left: 0, right: 0,
              child: BusListWidget(
                animation: busStAni,
                busList: busList,
                onRefresh: updateBusListBox,
                onScrollToTop: busStationBoxClick,
              ),
            ),

            // 1.4 선택한 버스정류장에 대한 정보 표시 위젯
            Positioned(
              bottom: busStAni.value,
              left: 0, right: 0,
              height: MediaQuery.of(context).size.height * 0.125,
              child: SubWidget(onClick: busStationBoxClick, busStation: busStopInfos[curBusStop], numOfBus: numOfBus,),
            ),

            // 1.5 로딩 위젯
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
