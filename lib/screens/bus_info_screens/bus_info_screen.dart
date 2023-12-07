import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/bus_info_screens/loading_screen.dart';
import 'package:kumoh_road/widgets/outline_circle_button.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import '../../models/bus_station_model.dart';
import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_providers.dart';
import '../../widgets/bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;

import '../../widgets/bus_chat_widget.dart';
import '../../widgets/bus_station_widget.dart';

class ButtonData {
  final IconData icon;
  final int nextBusSt;
  final int clickMark;
  ButtonData(this.icon, this.nextBusSt, this.clickMark);
}


class BusInfoScreen extends StatefulWidget {
  const BusInfoScreen({super.key});

  @override
  State<BusInfoScreen> createState() => _BusInfoScreenState();
}

class _BusInfoScreenState extends State<BusInfoScreen> with TickerProviderStateMixin {

  // 로딩 상태
  late bool   isLoading      = true;
  late double loadingOpacity = 1.0;
  
  // api 호출주소
  final apiAddr = 'http://apis.data.go.kr/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList';
  final serKey  = 'ZjwvGSfmMbf8POt80DhkPTIG41icas1V0hWkj4cp5RTi1Ruyy2LCU02TN8EJKg0mXS9g2O8B%2BGE6ZLs8VUuo4w%3D%3D';

  // 파이어베이스
  final fire = FirebaseFirestore.instance;

  // 지도 컨트롤러
  late NaverMapController con;
  bool isMapMoved = false;

  // 지도의 마크와 마크 위에 띄울 위젯
  final busStopMarks = [
    NMarker(position: NLatLng(36.12963461, 128.3293215), id: "구미역",),
    NMarker(position: NLatLng(36.12802335, 128.3331997), id: "농협",),
    NMarker(position: NLatLng(36.14317057, 128.3943957), id: "금오공대종점",),
    NMarker(position: NLatLng(36.13948442, 128.3967393), id: "금오공대입구(옥계중학교방면)",),
    NMarker(position: NLatLng(36.12252942, 128.3510414), id: "종합버스터미널",),
  ];
  late final busStopW;
  
  // 위치 이동 버튼과 상태
  late List<OutlineCircleButton> buttons;
  late int curButton = 0;

  // 애니메이션 컨트롤러
  late AnimationController busStAnicon   = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
  late AnimationController commentAnicon = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
  late CurvedAnimation busStCurveAni     = CurvedAnimation(parent: busStAnicon,   curve: Curves.easeInOutExpo);
  late CurvedAnimation commentCurveAni   = CurvedAnimation(parent: commentAnicon, curve: Curves.easeInOutExpo);

  // 버스정류장, 위치교체버튼, 버스목록, 댓글 애니메이션
  late Animation<double> busStAni;
  late Animation<double> chBtnAni;
  late Animation<double> busListAni;
  late Animation<double> commentAni;

  // 두 지역(구미역, 금오공대)에 대한 화면 포지션 정의
  static const gumiPos     = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
  static const gumiSPos    = NCameraPosition(target: NLatLng(36.12567222, 128.3313162), zoom: 15.2, bearing: 0, tilt: 0);
  static const kumohPos    = NCameraPosition(target: NLatLng(36.14132749, 128.3955675), zoom: 15.5, bearing: 0, tilt: 0);
  static const kumohSPos   = NCameraPosition(target: NLatLng(36.13420749, 128.3955675), zoom: 14.0, bearing: 0, tilt: 0);
  static const terminalPos = NCameraPosition(target: NLatLng(36.12252942, 128.3510414), zoom: 15.5, bearing: 0, tilt: 0);
  static const terminalSPos= NCameraPosition(target: NLatLng(36.12002942, 128.3510414), zoom: 15.5, bearing: 0, tilt: 0);
  
  // 지역 이동할 때 사용
  final cameras = [
    NCameraUpdate.scrollAndZoomTo(target: gumiPos.target,   zoom: gumiPos.zoom),  // 구미역
    NCameraUpdate.scrollAndZoomTo(target: gumiSPos.target,  zoom: gumiSPos.zoom), // 구미역 축소
    NCameraUpdate.scrollAndZoomTo(target: kumohPos.target,  zoom: kumohPos.zoom), // 금오공대
    NCameraUpdate.scrollAndZoomTo(target: kumohSPos.target, zoom: kumohSPos.zoom),// 금오공대 축소
    NCameraUpdate.scrollAndZoomTo(target: terminalPos.target,  zoom: terminalPos.zoom), // 종합터미널
    NCameraUpdate.scrollAndZoomTo(target: terminalSPos.target, zoom: terminalSPos.zoom) // 종합터미널 축소
  ];
  final cameraMap =  [0,2,4]; // 구미역, 금오공대, 종합터미널

  // 자주 사용할 거 같은
  NCameraAnimation myFly = NCameraAnimation.fly;
  Duration myDuration    = Duration(milliseconds: 200);

  // 버스정류장 위젯 애니메이션 감지
  bool isBusWidgetTop      = false;
  bool isCommentWidgetOpen = false;

  // 버스정류장 정보와 그 상태들
  final busStopInfos = [
    BusSt(code:"GMB80", id:10080,subText:'경상북도 구미시 구미중앙로 70',  mainText:'구미역'),
    BusSt(code:"GMB167",id:10167,subText:'경상북도 구미시 원평동 1008-40',mainText:'농협'),
    BusSt(code:"GMB132",id:10132,subText:'경상북도 구미시 거의동 550',    mainText:'금오공대종점'),
    BusSt(code:"GMB131",id:10131,subText:'경상북도 구미시 거의동 589-8',  mainText:'금오공대입구(옥계중학교방면)'),
    BusSt(code: "GMB91",id:10091,subText: "경상북도 구미시 원평동 1103",  mainText: '종합버스터미널'),
  ];
  late int    curBusStop = 0;
  late String curBusCode = "";
  late List<Bus> busList    = [];

  // 댓글 정보와 그 상태들
  late List<Comment>   comments     = [];
  late List<UserModel> commentUsers = [];
  late bool isValidUser = false;

  Future<void> getComments() async {
    setState(() { isLoading = true;});

    final commentDoc =     fire.collection('bus_chat').doc(curBusCode);
    final userCollection = fire.collection('users');

    // 버스에 대한 comments 가져오기
    DocumentSnapshot commentData = await commentDoc.get();
    CommentList commentlist = CommentList.fromDocument(commentData,extraData: curBusCode);

    // 각 comment에 대한 유저 가져오기
    List<UserModel> tempUsers = [];
    for (final comment in commentlist.comments) {
      try {
        final users = await userCollection.doc(comment.writerId).get();
        final user = UserModel.fromDocument(users);
        tempUsers.add(user);
      } catch(e) { print('get user data about comment error : ${e.toString()}');}
    }

    setState(() { comments = commentlist.comments; commentUsers = tempUsers; isLoading = false;});
  }

  List<ButtonData> buttonData = [
    ButtonData(Icons.school_outlined,                1, 2),
    ButtonData(Icons.directions_bus_filled_outlined, 2, 4),
    ButtonData(Icons.tram_outlined,                  0, 0),
  ];

  void reAnimation(double screenHeight, Orientation orientation) {
    busStAni =   Tween(begin: 0.0,                  end: screenHeight * 0.50).animate(busStAnicon)    ..addListener(() {setState(() {});});
    chBtnAni =   Tween(begin: screenHeight * 0.035, end: screenHeight * 0.53).animate(busStAnicon)    ..addListener(() {setState(() {});});
    busListAni = Tween(begin: screenHeight * 0.035, end: screenHeight * 1.00).animate(busStAnicon)    ..addListener(() {setState(() {});});
    commentAni = Tween(begin: screenHeight * 0.035, end: screenHeight * 1.00).animate(commentCurveAni)..addListener(() {setState(() {});});
  }

  @override
  void initState() {
    super.initState();

    buttons = buttonData.map((data) =>
      OutlineCircleButton(
        child: Icon(data.icon, color: Colors.white), radius: 50.0, borderSize: 0.5,
        foregroundColor: const Color(0xFF3F51B5), borderColor: Colors.white,
        onTap: () async {
          await busStopMarks[data.clickMark].performClick();
          final nextBusSt = data.nextBusSt;
          if (busStAnicon.isDismissed){
            cameras[cameraMap[nextBusSt]].setAnimation(animation: myFly, duration: myDuration);
            await con.updateCamera(cameras[cameraMap[nextBusSt]]);
          } else {
            cameras[cameraMap[nextBusSt]+1].setAnimation(animation: myFly, duration: myDuration);
            await con.updateCamera(cameras[cameraMap[nextBusSt]+1]);
          }
          setState(() { isMapMoved = false; curButton = data.nextBusSt; });
        },
      )
    ).toList();

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
    final userProvider = Provider.of<UserProvider>(context)..startListeningToUserChanges();
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenHeight     = MediaQuery.of(context).size.height;

    // 버스리스트 가져올 때 파이어베이스의 버스리스트를 업데이트하는 함수
    Future<BusList> compareSources(BusList busListFromApi, final nodeId) async {
      final stationDoc = fire.collection('bus_station_info').doc(nodeId);
      BusList buslistFromFire, newBusListToFire = BusList(buses: []);

      // 파베에 저장되어있는 bus_list 가져옴
      DocumentSnapshot station = await stationDoc.get();
      buslistFromFire = BusList.fromDocument(station);

      // 각 버스의 도착지 결정해야 - 마지막에..
      print('도착지는요? - 미안합니다..');

      // 두 코드 리스트에서 공통된(기존) 버스 찾아 추가 - 정보 업데이트
      for (var fireBus in buslistFromFire.buses) {
        for (var apiBus in busListFromApi.buses) {
          if (fireBus == apiBus) { 
            fireBus.arrprevstationcnt = apiBus.arrprevstationcnt;
            fireBus.arrtime = apiBus.arrtime;
            newBusListToFire.buses.add(fireBus);
            break;
          }
        }
      }

      // 두 코드 리스트에서 공통된 버스 무시
      for (var sameBus in newBusListToFire.buses) {
        busListFromApi.buses.removeWhere((apiBus)   => apiBus == sameBus); // 파베에서 추가해야 할 버스들만 남음
        buslistFromFire.buses.removeWhere((fireBus) => fireBus == sameBus);// 파베에서 제거해야 할 버스들만 남음
      }

      // (지나간 버스 newBusListToFire에 추가하지 않음 == 파베에서 버스 삭제), 지나간 채팅 복제하고 문서이름만 다르게
      for (Bus bus in buslistFromFire.buses) {
        try {
          DateTime now = DateTime.now(); // 새 문서의 이름에 사용될
          DocumentSnapshot chat = await fire.collection('bus_chat').doc(bus.code).get(); // 원본 댓글리스트 가져와
          if (chat.exists) {
            final Map<String, dynamic> chatData = chat.data() as Map<String,dynamic>;    // 데이터 추출해
            chatData['passed'] = true;

            // report에 해당 버스의 댓글이 있다면 entityId(모든정보), reason(버스지나감) 으로 수정
            final reportDoc = FirebaseFirestore.instance.collection('reports');
            final mustBeModify = await reportDoc.where('reason', isEqualTo: bus.code).get();
            for (var doc in mustBeModify.docs) {
              final commentTime = doc.get('entityId') as String;
              await reportDoc.doc(doc.id).update({'entityId': '${commentTime}-${now}-${bus.code}'});
              await reportDoc.doc(doc.id).update({'reason': 'passedBus'});
            }

            fire.collection('bus_chat').doc(bus.code).delete();                          // 원본 댓글리스트 삭제해
            if ((chatData['comments'] as List<dynamic>).isNotEmpty) {
              fire.collection('bus_chat').doc('${now}-${bus.code}').set(chatData);       // 추출한 데이터(댓글)가 존재하면 새로운 이름의 문서로 추가
            }
          }
        } catch(e) {print('passed bus chat document update error : ${e}');}
      }

      // // 새 버스는 그냥 추가, 채팅 문서 추가
      for (Bus bus in busListFromApi.buses) {
        newBusListToFire.buses.add(bus);
        try{ await fire.collection('bus_chat').doc(bus.code).set({'comments': [], 'passed': false});}
          catch(e) { print('adding new bus chat list error : ${e.toString()}');}
      }

      // 수정한 목록을 파베,입력에 업데이트
      await stationDoc.update({'busList': newBusListToFire.getArrayFormat()});
      return newBusListToFire;
    }

    // 버스리스트를 api에서 가져오는 함수
    Future<BusList> getBusListFromApi(final nodeId) async {
      try {
        final res = await http.get(Uri.parse('${apiAddr}?serviceKey=${serKey}&_type=json&cityCode=37050&nodeId=${nodeId}'));
        BusList buslist, newBusList;

        final decodeRes = jsonDecode(utf8.decode(res.bodyBytes));

        if (res.statusCode == 200) { // 파베에 업뎃시켜
          try{
            buslist = BusList.fromJson(decodeRes);
            newBusList = await compareSources(buslist, nodeId);
          } catch(e) {newBusList = BusList.fromJson({}); throw Exception(e);}
          return (newBusList);
        }
        else { throw Exception('Failed to load buses info');}

      } catch(e) { print('getBusListFromApi error : ${e.toString()}'); return BusList.fromJson({});}
    }

    // 정류장의 정보 가져오는 함수
    Future<BusList> fetchBusInfo(final nodeId) async {
      final stationDoc = fire.collection('bus_station_info').doc(nodeId);
      DocumentSnapshot station = await stationDoc.get();
      BusList buslist;

      if (station.exists) {
        // 정보 중 마지막 업데이트 시간 확인
        DateTime now = DateTime.now(), lastUpdate = station.get('lastUpdate').toDate(); // 불길
        var difference = now.difference(lastUpdate);

        // 마지막 업데이트 후 10분이 넘었다 - api 호출 새 버스리스트 받아옴
        if (difference.inMinutes >= 10) { print("업데이트 - api!! ${nodeId}");
          setState(() { isLoading = true;});

          try{
            buslist = await getBusListFromApi(nodeId);
            // buslist = BusList.fromJson({}); 확인용
            await stationDoc.update({'lastUpdate': Timestamp.fromDate(now)}); // 진행되면 업뎃하게끔
          } catch(e) { print('try station update error : ${e.toString()}'); return BusList.fromJson({});}

          setState(() { isLoading = false;});
          return buslist;
        }

        // 업데이트 한 지 10분이 안 됨 - 파베에서 그대로 받아옴
        else { print("업데이트 - 파베!! ${nodeId}");
          try {
            buslist = BusList.fromDocument(station);
          } catch(e) { print('try station get error : ${e.toString()}'); return BusList.fromJson({});}
          return buslist;
        }

      }
      else { print('Failed to load that bus station'); return BusList.fromJson({});}
    }

    // 정류장 정보 얻어와 리스트 저장하는 함수
    Future<void> updateBusListBox() async {
      setState(() { isLoading = true;});
      BusList buslist = await fetchBusInfo(busStopInfos[curBusStop].code);

      setState(() { busList = buslist.buses; isLoading = false;});
    }


    // 댓글을 슬라이드할 때 이벤트 처리 함수
    Future<void> commentsBoxSlide() async {
      if (MediaQuery.of(context).viewInsets.bottom == 0) { // 댓글 쓰다가 내려가지 않게
        if (commentAnicon.isDismissed) {
          await commentAnicon.forward(); // 댓글 들고오기
          await getComments();
          setState(() {isCommentWidgetOpen = true;});
        }
        else if (commentAnicon.isCompleted) {
          await commentAnicon.reverse();
          setState(() {isCommentWidgetOpen = false;});
        }
      }
    }

    // 버스 업데이트 버튼 클릭 시 이벤트 처리 함수
    Future<void> updateBusStop(int busStop) async {
      setState(() { curBusStop = busStop; });
      (isCommentWidgetOpen) ? commentsBoxSlide() : null;
      busStopMarks[busStop].setIcon(NOverlayImage.fromAssetImage('assets/images/main_marker.png'));

      for (int i = 0; i < 5; i++){
        if (busStop != i) {
          try { await busStopW[i].close();} catch (e) { }
          try { busStopMarks[i].setIcon(NOverlayImage.fromAssetImage('assets/images/sub_marker.png')); } catch (e) {}
        }
      }

      await updateBusListBox();
      setState(() {isLoading = false; loadingOpacity = 0.8;});
    }

    // 버스정류장 정보를 슬라이드할 때 이벤트 처리 함수
    Future<void> busStationBoxSlide() async {
      if (isCommentWidgetOpen == false){
        if (busStAnicon.isDismissed) {
          busStAnicon.forward();
          setState(() { isBusWidgetTop = true;});

          final index = (curBusStop%2)==1 ? curBusStop : curBusStop+1;
          cameras[index].setAnimation(animation: myFly, duration: myDuration);
          await con.updateCamera(cameras[index]);
        }
        else if (busStAnicon.isCompleted) {
          busStAnicon.reverse();
          setState(() { isBusWidgetTop = false;});

          final index = (curBusStop%2)==0 ? curBusStop : curBusStop-1;
          cameras[index].setAnimation(animation: myFly, duration: myDuration);
          await con.updateCamera(cameras[index]);
        }
      }
    }


    // 버스리스트에서 댓글 활성화버튼 이벤트 처리
    Future<void> callComments(String busCode) async {
      setState(() { curBusCode = busCode; comments = []; commentUsers = []; });
      await commentsBoxSlide();
    }

    // 댓글 등록 시 이벤트 처리
    void submitComment(String comment) async {

      // 댓글 문서 가져오기
      final chatDoc = fire.collection('bus_chat').doc(curBusCode);
      //final chatDoc = fire.collection('bus_chat_temp').doc('GMB131-190-GMB19020');

      // 문서의 comments 필드에 추가
      await chatDoc.update({
        'comments' : FieldValue.arrayUnion([{
          'comment': comment,
          'enable': true,
          'createdTime' : Timestamp.now(),
          'writerId': userProvider.id.toString(),
        }])
      });
      
      // 유저의 코멘트 수 증가
      await userProvider.updateUserInfo(commentCount: userProvider.commentCount+1);

      // 댓글 다시 불러오기
      await getComments();
    }


    reAnimation(screenHeight, orientation); // 기기의 화면 크기로 애니메이션 재설정

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
                rotationGesturesEnable: false, scrollGesturesEnable: true, tiltGesturesEnable: false, stopGesturesEnable: false, scaleBarEnable: false, logoClickEnable: false,
              ),
              // 1.1.2맵과 관련된 로직 정의
              onMapReady: (NaverMapController controller) async {
                // 1.1.2.1 맵 컨트롤러 등록
                con = controller;
                // 1.1.2.2 각 마커를 클릭했을 때의 이벤트 지정
                for (int i = 0; i < 5; i++){
                  con.addOverlay(busStopMarks[i]);
                  busStopMarks[i].setOnTapListener((overlay) async { (isCommentWidgetOpen) ? commentsBoxSlide() : null; await busStopMarks[i].openInfoWindow(busStopW[i]); await updateBusStop(i); });
                }
                // 1.1.2.3 구미역 버튼 클릭
                await busStopMarks[0].performClick();
              },
              onCameraChange: (reason, animated) => {
                if(reason== NCameraUpdateReason.gesture) {setState((){ isMapMoved=true;})}
              },
            ),

            // 1.2 버스 리스트 위젯
            Positioned(
              bottom: busListAni.value - screenHeight, left: 0, right: 0,
              child: BusListWidget(
                busList: busList,
                isLoading: isLoading,
                onRefresh: updateBusListBox,
                onScrollToTop: busStationBoxSlide,
                onCommentsCall: (String busCode){ callComments(busCode); },
              ),
            ),

            // 1.3 선택한 버스정류장에 대한 정보 표시 위젯
            Positioned(
              bottom: busStAni.value,
              left: 0, right: 0,
              height: (orientation == Orientation.portrait) ? MediaQuery.of(context).size.height * 0.125  : MediaQuery.of(context).size.height * 0.25,
              child: BusStationWidget(onClick: busStationBoxSlide, busStation: busStopInfos[curBusStop], isTop: isBusWidgetTop,),
            ),

            // 1.4.1 위치 변경 버튼 위젯
            Positioned(
              bottom: chBtnAni.value,
              right: MediaQuery.of(context).size.width * 0.05,
              child: buttons[curButton],
            ),

            // 1.4.2 제자리 돌아오는 버튼 위젯 - 움직일 때만 활성화되어야 하는데..
            Positioned(

              bottom: chBtnAni.value,
              right: MediaQuery.of(context).size.width * 0.2,
              child: OutlineCircleButton(
                child: Icon(Icons.undo_outlined, color: Colors.white), radius: 50.0, borderSize: 0.5,
                foregroundColor: (isMapMoved) ? const Color(0xFF3F51B5) : Colors.white, borderColor: Colors.white,
                onTap: () {
                  if(isMapMoved) {
                    final toCurLocationButtonIndex = ((curButton-1) >= 0) ? curButton - 1 : buttons.length - 1;
                    buttons[toCurLocationButtonIndex].onTap();
                  }
                },

              ),
            ),

            // 1.5 댓글 위젯
            Positioned(
              bottom: commentAni.value - screenHeight, left: 0, right: 0,
              child: BusChatListWidget(
                onScrollToTop: commentsBoxSlide,
                submitComment: submitComment,
                updateComment: getComments,
                isLoading:     isLoading,
                comments:      comments,
                commentUsers:  commentUsers,
                userProvider: userProvider,
              )
            ),

            // 1.6 첫 로딩 위젯
            LoadingScreen(limitTime: true, opacity: loadingOpacity, miliTime: 1100,),
          ],
        ),
      ),

      // 2. 어플 공통의 네비게이션 바
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 2,),
    );
  }

  @override
  void dispose() {
    busStAnicon.dispose(); super.dispose();
  }
}
