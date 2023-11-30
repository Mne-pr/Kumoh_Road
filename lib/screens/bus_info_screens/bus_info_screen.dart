import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kumoh_road/screens/bus_info_screens/loading_screen.dart';
import 'package:kumoh_road/widgets/outline_circle_button.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../models/bus_station_model.dart';
import '../../widgets/bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;

import '../../widgets/bus_station_widget.dart';

class BusInfoScreen extends StatefulWidget {
  const BusInfoScreen({super.key});

  @override
  State<BusInfoScreen> createState() => _BusInfoScreenState();
}

class _BusInfoScreenState extends State<BusInfoScreen> with TickerProviderStateMixin {

  // 로딩 상태
  late bool isLoading = true;
  late double loadingOpacity = 1.0;
  
  // api 호출주소
  final apiAddr = 'http://apis.data.go.kr/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList';
  final serKey = 'ZjwvGSfmMbf8POt80DhkPTIG41icas1V0hWkj4cp5RTi1Ruyy2LCU02TN8EJKg0mXS9g2O8B%2BGE6ZLs8VUuo4w%3D%3D';

  // 파이어베이스
  final fire = FirebaseFirestore.instance;

  // 지도 컨트롤러
  late NaverMapController con;
  
  // 지도의 마크와 마크 위에 띄울 위젯
  final busStopMarks = [
    NMarker(position: NLatLng(36.12963461, 128.3293215), id: "구미역"),
    NMarker(position: NLatLng(36.12802335, 128.3331997), id: "농협"),
    NMarker(position: NLatLng(36.14317057, 128.3943957), id: "금오공대종점"),
    NMarker(position: NLatLng(36.13948442, 128.3967393), id: "금오공대입구(옥계중학교방면)"),
    NMarker(position: NLatLng(36.12252942, 128.3510414), id: "종합버스터미널"),
  ];
  late final busStopW;
  
  // 버스정류장 정보와 그 상태들
  final busStopInfos = [
    BusSt(code:"GMB80", id:10080,subText:'경상북도 구미시 구미중앙로 70',  mainText:'구미역'),
    BusSt(code:"GMB167",id:10167,subText:'경상북도 구미시 원평동 1008-40',mainText:'농협'),
    BusSt(code:"GMB132",id:10132,subText:'경상북도 구미시 거의동 550',    mainText:'금오공대종점'),
    BusSt(code:"GMB131",id:10131,subText:'경상북도 구미시 거의동 589-8',  mainText:'금오공대입구(옥계중학교방면)'),
    BusSt(code: "GMB91",id:10091,subText: "경상북도 구미시 원평동 1103",  mainText: '종합버스터미널'),
  ];
  late int curBusStop = 0;
  late List<Bus> busList = [];
  
  // 위치 이동 버튼과 상태
  late List<OutlineCircleButton> buttons;
  late int curButton = 0;

  // 애니메이션 컨트롤러
  late AnimationController busStAnicon = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
  late CurvedAnimation busStCurveAni =   CurvedAnimation(parent: busStAnicon, curve: Curves.easeInOutExpo);
  
  // 버스정류장, 위치교체버튼 애니메이션
  late Animation<double> busStAni;
  late Animation<double> chBtnAni;

  // 두 지역(구미역, 금오공대)에 대한 화면 포지션 정의
  static const gumiPos  = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
  static const gumiSPos = NCameraPosition(target: NLatLng(36.12727222, 128.3315162), zoom: 15.2, bearing: 0, tilt: 0);
  static const kumohPos = NCameraPosition(target: NLatLng(36.14132749, 128.3955675), zoom: 15.5, bearing: 0, tilt: 0);
  static const kumohSPos= NCameraPosition(target: NLatLng(36.13762749, 128.3955675), zoom: 14.0, bearing: 0, tilt: 0);
  static const terminalPos = NCameraPosition(target: NLatLng(36.12252942, 128.3510414), zoom: 15.5, bearing: 0, tilt: 0);
  static const terminalSPos= NCameraPosition(target: NLatLng(36.12082942, 128.3510414), zoom: 15.5, bearing: 0, tilt: 0);
  
  // 지역을 이동할 때 사용하는 것
  final cameras = [
    NCameraUpdate.scrollAndZoomTo(target: gumiPos.target,   zoom: gumiPos.zoom),  // 구미역
    NCameraUpdate.scrollAndZoomTo(target: gumiSPos.target,  zoom: gumiSPos.zoom), // 구미역 축소
    NCameraUpdate.scrollAndZoomTo(target: kumohPos.target,  zoom: kumohPos.zoom), // 금오공대
    NCameraUpdate.scrollAndZoomTo(target: kumohSPos.target, zoom: kumohSPos.zoom),// 금오공대 축소
    NCameraUpdate.scrollAndZoomTo(target: terminalPos.target,  zoom: terminalPos.zoom), // 종합터미널
    NCameraUpdate.scrollAndZoomTo(target: terminalSPos.target, zoom: terminalSPos.zoom) // 종합터미널 축소
  ];
  final cameraMap =  [0,2,4]; // 구미역, 금오공대, 종합터미널

  // 자주 쓸 거 같은
  NCameraAnimation myFly = NCameraAnimation.fly;
  Duration myDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();

    // 반복문으로 줄일 수 있을 것 같음!! - 나중에
    buttons = [
      OutlineCircleButton( // 구미역 -> 금오공대
        child: Icon(Icons.school_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
        foregroundColor: Color(0xff05d686),borderColor: Colors.white,
        onTap: () async {
          await busStopMarks[2].performClick();
          final nextBusSt = 1;
          if (busStAnicon.isDismissed){
            cameras[cameraMap[nextBusSt]].setAnimation(animation: myFly, duration: myDuration); // 사실 cameraMap[0] 대신에 0 넣으면 되는데 보기 편하라고
            await con.updateCamera(cameras[cameraMap[nextBusSt]]);
          } else {
            cameras[cameraMap[nextBusSt]+1].setAnimation(animation: myFly, duration: myDuration);
            await con.updateCamera(cameras[cameraMap[nextBusSt]+1]);
          }
          setState(() { curButton = 1; });
        },
      ),
      OutlineCircleButton( // 금오공대 -> 종합터미널
        child: Icon(Icons.directions_bus_filled_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
        foregroundColor: Color(0xff05d686), borderColor: Colors.white,
        onTap: () async {
          await busStopMarks[4].performClick();
          final nextBusSt = 2;
          if (busStAnicon.isDismissed){
            cameras[cameraMap[nextBusSt]].setAnimation(animation: myFly, duration: myDuration);
            await con.updateCamera(cameras[cameraMap[nextBusSt]]);
          } else {
            cameras[cameraMap[nextBusSt]+1].setAnimation(animation: myFly, duration: myDuration);
            await con.updateCamera(cameras[cameraMap[nextBusSt]+1]);
          }
          setState(() { curButton = 2; });
        }
      ),
      OutlineCircleButton( // 종합터미널 -> 구미역
          child: Icon(Icons.tram_outlined, color: Colors.white,), radius: 50.0, borderSize: 0.5,
          foregroundColor: Color(0xff05d686),borderColor: Colors.white,
          onTap: () async {
            await busStopMarks[0].performClick();
            final nextBusSt = 0;
            if (busStAnicon.isDismissed){
              cameras[cameraMap[nextBusSt]].setAnimation(animation: myFly, duration: myDuration);
              await con.updateCamera(cameras[cameraMap[nextBusSt]]);
            } else {
              cameras[cameraMap[nextBusSt]+1].setAnimation(animation: myFly, duration: myDuration);
              await con.updateCamera(cameras[cameraMap[nextBusSt]+1]);
            }
            setState(() { curButton = 0; });
          }
      ),

    ];

    busStopW = [
      NInfoWindow.onMarker(id: busStopMarks[0].info.id, text: busStopInfos[0].mainText),
      NInfoWindow.onMarker(id: busStopMarks[1].info.id, text: busStopInfos[1].mainText),
      NInfoWindow.onMarker(id: busStopMarks[2].info.id, text: busStopInfos[2].mainText),
      NInfoWindow.onMarker(id: busStopMarks[3].info.id, text: busStopInfos[3].mainText),
      NInfoWindow.onMarker(id: busStopMarks[4].info.id, text: busStopInfos[4].mainText),
    ];

  }

  @override
  Widget build(BuildContext context) {

    // 기기의 화면 크기를 이용해 애니메이션 재설정
    double screenHeight = MediaQuery.of(context).size.height;
    busStAni = Tween(begin: 0.0, end: screenHeight * 0.78).animate(busStCurveAni)
      ..addListener(() {setState(() {});});
    chBtnAni = Tween(begin: screenHeight * 0.035, end: screenHeight * 0.52).animate(busStCurveAni)
      ..addListener(() {setState(() {});});

    // 버스리스트 가져올 때 파이어베이스의 버스리스트를 업데이트하는 함수
    Future<void> compareSources(List<Bus> busListFromApi, final nodeId) async {
      final DocumentSnapshot check;
      List<String> busCodesFromFire;
      final curDoc = fire.collection('bus_station_info').doc(nodeId);
      var tmpBusList;

      // 파베의 bus_list에서 업데이트 할 버스정류장의 문서 이름 리스트를 가져옴
      try {
        check = await curDoc.get();
        tmpBusList = check.get('bus_list');
        busCodesFromFire = tmpBusList.map<String>((bus) => bus['code'] as String).toList();
      } catch(error) {print("get bus_list error : ${error.toString()}"); busCodesFromFire = [];}

      // api 리스트로부터 이름을 가져옴 - 고유문자 생성
      List<String> busCodesFromApi = busListFromApi.map((bus) {
        var code = '${bus.nodeid}-${bus.routeno}-${bus.routetp}';
        bus.setCode(code);
        return bus.code;
      }).toList();
      print('fire_code_list : ${busCodesFromFire.toString()}, api_list : ${busCodesFromApi.toString()}');

      // 두 코드 리스트에서 공통된 버스 찾음
      Set<String> commonCodes = busCodesFromFire.toSet().intersection(busCodesFromApi.toSet());

      // 두 코드 리스트에서 공통된 버스 제거
      busCodesFromFire.removeWhere((name) => commonCodes.contains(name)); // 파베에서 제거해야 할 버스들만 남음
      busCodesFromApi.removeWhere((name) => commonCodes.contains(name));  // 파베에 추가해야 할 버스들만 남음

      // 버스 목록에서 지나간 버스 제거
      for (String code in busCodesFromFire) {
        tmpBusList.removeWhere((bus) => bus['code'] == code);
        //////// 파베에 버스 채팅리스트도 지워야 함!!!!!
        try{
          await fire.collection('bus_chat').doc(code).delete();
        } catch(e) {}
      }

      // 새 버스를 추가, 기존 버스 업데이트
      for (Bus bus in busListFromApi) {
        // 새로운 버스인 경우 - 추가
        if (busCodesFromApi.contains(bus.code)) {
          tmpBusList.add({
            'arrprevstationcnt': bus.arrprevstationcnt, // 남은 정류장 수
            'arrtime':   bus.arrtime,   // 도착예상시간(초)
            'nodeid':    bus.nodeid,    // 정류소 ID
            'nodenm':    bus.nodenm,    // 정류소명
            'routeid':   bus.routeid,   // 노선 ID
            'routeno':   bus.routeno,   // 노선번호 - 버스번호
            'routetp':   bus.routetp,   // 노선유형
            'vehicletp': bus.vehicletp, // 자량유형
            'code':      bus.code,      // 고유문자
          });
          //////// 파베에 버스 채팅리스트도 만들어야 함!!!!!
          await fire.collection('bus_chat').doc(bus.code).set({});
        }

        // 기존 버스인 경우 - 업데이트
        else {
          var busToUpdate = tmpBusList.firstWhere((b) => b['code'] == bus.code);
          busToUpdate['arrprevstationcnt'] = bus.arrprevstationcnt;
          busToUpdate['arrtime'] = bus.arrtime;
        }
      }
      print('제거해야 할 버스 : ${busCodesFromFire.toString()}, 추가해야 할 버스 : ${busCodesFromApi.toString()}');

      // 수정한 목록을 파베에 업데이트
      await curDoc.update({'bus_list': tmpBusList});
      return;
    }

    // 버스리스트를 api에서 가져오는 함수
    Future<BusApiRes> getBusListFromApi(final nodeId) async {
      try {
        final res = await http.get(Uri.parse(
            '${apiAddr}?serviceKey=${serKey}&_type=json&cityCode=37050&nodeId=${nodeId}'));
        if (res.statusCode == 200) {
          // 파베에 새 버스리스트로 업데이트시킴
          final fromApi = BusApiRes.fromJson(
              jsonDecode(utf8.decode(res.bodyBytes)));
          await compareSources(fromApi.buses, nodeId);
          return (fromApi);
        }
        else {
          throw Exception('Failed to load buses info');
        }
      } catch(e) { throw Exception(e); }
    }

    // 정류장의 정보 가져오는 함수 - 아래 두 함수에서 호출함
    Future<BusApiRes> fetchBusInfo(final nodeId) async {
      final curDoc = fire.collection('bus_station_info').doc(nodeId);
      // 해당 버스정류장의 정보 가져오기
      var station = await curDoc.get();
      final busList;

      if (station.exists) {
        // 정보 중 마지막 업데이트 시간 확인
        DateTime lastUpdate = station.get('last_update').toDate();
        DateTime now = DateTime.now();
        var difference = now.difference(lastUpdate);
        print('파베시간 : ${lastUpdate.toString()}');
        print('현재시간 : ${now.toString()}');

        // 마지막 업데이트 후 10분이 넘었다 - api 호출 새 버스리스트 받아옴
        if (difference.inMinutes >= 10) { print("업데이트 - api!! ${nodeId}");
          // 이렇게 api 새로 호출할 때만 로딩화면
          setState(() { isLoading = true;});
          try{
            // 마지막 업데이트를 현재 시간으로 수정
            await curDoc.update({'last_update': Timestamp.fromDate(now)});
            busList = await getBusListFromApi(nodeId);
            setState(() { isLoading = false;});
            return busList;
          } catch(e) {print(e); return BusApiRes.fromJson({});}
        }

        // 업데이트 한 지 10분이 안 됨 - 파베에서 그대로 받아옴
        else { print("업데이트 - 파베!! ${nodeId}");
          try {
            final fire = await curDoc.get();
            List<Map<String,dynamic>> newBusList = [];
            if (fire.exists) {
              busList = await fire.get('bus_list');
              for (var b in busList) { newBusList.add(b);}
              final res = BusApiRes.fromFirestore(newBusList);
              return res;
            }
            else { throw Exception();}
            // 위의 코드 수정할 필요 있어보임
          } catch(e) {print(e); return BusApiRes.fromJson({});}
        }
      }
      else { print('Failed to load that bus station'); return BusApiRes.fromJson({});}
    }

    // 정류장 정보 얻어와 리스트 저장하는 함수
    Future<void> updateBusListBox() async {
      BusApiRes res = await fetchBusInfo(busStopInfos[curBusStop].code);
      setState(() { busList = res.buses;});
    }

    // 버스 업데이트 버튼 리스너
    Future<void> updateBusStop(int busStop) async {
      setState(() { curBusStop = busStop; });//isLoading = true; });
      await updateBusListBox();
      busStopMarks[busStop].setIconTintColor(Color.fromARGB(0, 1, 1, 255));

      for (int i = 0; i < 5; i++){
        if (busStop != i) {
          try { await busStopW[i].close();} catch (e) { }
          try { busStopMarks[i].setIconTintColor(Colors.transparent); } catch (e) {}
        }
      }
      await Future.delayed(Duration(milliseconds: 250));
      setState(() {isLoading = false; loadingOpacity = 0.8;});
    }

    // 버스정류장 정보를 클릭할 때 이벤트 처리
    Future<void> busStationBoxClick() async {
      if (busStAnicon.isDismissed) {
        busStAnicon.forward();

        final index = (curBusStop%2)==1 ? curBusStop : curBusStop+1;
        cameras[index].setAnimation(animation: myFly, duration: myDuration);
        await con.updateCamera(cameras[index]);
      }
      else if (busStAnicon.isCompleted) {
        busStAnicon.reverse();

        final index = (curBusStop%2)==0 ? curBusStop : curBusStop-1;
        cameras[index].setAnimation(animation: myFly, duration: myDuration);
        await con.updateCamera(cameras[index]);
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
                for (int i = 0; i < 5; i++){
                  con.addOverlay(busStopMarks[i]);
                  busStopMarks[i].setOnTapListener((overlay) async { await updateBusStop(i); await busStopMarks[i].openInfoWindow(busStopW[i]);});
                }
                // 1.1.2.3 구미역 버튼 클릭
                await busStopMarks[0].performClick();
              },
            ),

            // 1.2 버스 리스트 위젯
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.78, left: 0, right: 0,
              child: BusListWidget(
                animation: busStAni,
                busList: busList,
                onRefresh: updateBusListBox,
                onScrollToTop: busStationBoxClick,
              ),
            ),

            // 1.3 선택한 버스정류장에 대한 정보 표시 위젯
            Positioned(
              bottom: busStAni.value,
              left: 0, right: 0,
              height: MediaQuery.of(context).size.height * 0.125,
              child: BusStationWidget(onClick: busStationBoxClick, busStation: busStopInfos[curBusStop]),
            ),

            // 1.4 위치 변경 버튼 위젯
            Positioned(
              bottom: chBtnAni.value,
              right: MediaQuery.of(context).size.width * 0.05,
              child: buttons[curButton],
            ),

            // 1.5 로딩 위젯
            (isLoading == true) ? LoadingScreen(limitTime: false, opacity: loadingOpacity,) : SizedBox(width: 0,),
          ],
        ),
      ),

      // 2. 어플 공통의 네비게이션 바 배치
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 2,),
    );
  }

  @override
  void dispose() {
    busStAnicon.dispose(); super.dispose();
  }
}
