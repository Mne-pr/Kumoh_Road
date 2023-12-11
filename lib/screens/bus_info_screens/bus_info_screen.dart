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

class BusInfoScreen extends StatefulWidget {
  const BusInfoScreen({super.key});

  @override
  State<BusInfoScreen> createState() => _BusInfoScreenState();
}

class _BusInfoScreenState extends State<BusInfoScreen> with TickerProviderStateMixin {

  // 로딩 상태
  late bool   isLoading      = true;
  late double loadingOpacity = 1.0;

  // 자신의 정보
  late UserProvider userProvider;

  // 지도 컨트롤러
  late NaverMapController con;
  bool isMapMoved = false;

  // 사용할 버스정류장 위젯..?
  late final busStopW;
  
  // 위치 이동 버튼과 상태
  late List<OutlineCircleButton> buttons;
  late int curButton = 0;

  // 애니메이션 컨트롤러
  late AnimationController busStAnicon   = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
  late AnimationController commentAnicon = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);

  // 애니메이션
  late Animation<double> chBusListSizeAni;
  late Animation<double> chCommentSizeAni;

  // 댓글 컨트롤러
  final TextEditingController commentCon = TextEditingController();

  // 버스정류장 위젯 애니메이션 감지
  bool isBusStWidgetOpen   = false;
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

  // 화면 너비, 높이
  late Orientation orientation;
  late Size        screen;

  // 버스 챗리스트 위젯 관련
  bool isNoChat = true;
  bool isChatModifying = false;

  // 텍스트 입력 시
  void onTextChange() {
    if (commentCon.text.isEmpty || commentCon.text.trim().isEmpty || commentCon.text[0] == ' ') {
      setState(() { commentCon.text="";});
    }
    if (commentCon.text.length > 50) {
      setState(() { commentCon.text = commentCon.text.substring(0,50);});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('50자 이상 댓글을 달 수 없습니다'),duration: Duration(milliseconds: 250)),
      );
    }
    setState(() { isNoChat = commentCon.text.isEmpty;});
  }

  void modifyingChat() {
    setState(() { isChatModifying = true;});
  }

  // 버스리스트 가져올 때 파이어베이스의 버스리스트를 업데이트하는 함수
  Future<BusList> compareSources(BusList busListFromApi, final nodeId) async {
    final stationDoc = FIRE.collection('bus_station_info').doc(nodeId);
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
        DocumentSnapshot chat = await FIRE.collection('bus_chat').doc(bus.code).get(); // 원본 댓글리스트 가져와
        if (chat.exists) {
          final Map<String, dynamic> chatData = chat.data() as Map<String,dynamic>;    // 데이터 추출해
          chatData['passed'] = true;

          // report에 해당 버스의 댓글이 있다면 entityId(모든정보), reason(버스지나감) 으로 수정,
          // 왜 진작 reason을 nopass, pass로 하지 않았냐? => 지금 상황에서 해당 버스의 신고댓글들 찾기 편하려고
          final reportDoc = FirebaseFirestore.instance.collection('reports');
          final mustBeModify = await reportDoc.where('reason', isEqualTo: bus.code).get();
          for (var doc in mustBeModify.docs) {
            final commentTime = doc.get('entityId') as String;
            await reportDoc.doc(doc.id).update({'entityId': '${commentTime}-${now}-${bus.code}'});
            await reportDoc.doc(doc.id).update({'reason': 'passedBus'});
          }

          FIRE.collection('bus_chat').doc(bus.code).delete();                          // 원본 댓글리스트 삭제해
          if ((chatData['comments'] as List<dynamic>).isNotEmpty) {
            FIRE.collection('bus_chat').doc('${now}-${bus.code}').set(chatData);       // 추출한 데이터(댓글)가 존재하면 새로운 이름의 문서로 추가
          }
        }
      } catch(e) {print('passed bus chat document update error : ${e}');}
    }

    // // 새 버스는 그냥 추가, 채팅 문서 추가
    for (Bus bus in busListFromApi.buses) {
      newBusListToFire.buses.add(bus);
      try{ await FIRE.collection('bus_chat').doc(bus.code).set({'comments': [], 'passed': false});}
      catch(e) { print('adding new bus chat list error : ${e.toString()}');}
    }

    // 수정한 목록을 파베,입력에 업데이트
    await stationDoc.update({'busList': newBusListToFire.getArrayFormat()});
    return newBusListToFire;
  }

  // 버스리스트를 api에서 가져오는 함수
  Future<BusList> getBusListFromApi(final nodeId) async {
    try {
      final res = await http.get(Uri.parse('${BUS_API_ADDR}?serviceKey=${BUS_API_SERVICE_KEY}&_type=json&cityCode=37050&nodeId=${nodeId}'));
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
    final stationDoc = FIRE.collection('bus_station_info').doc(nodeId);
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
        setState(() {isCommentWidgetOpen = true;});
        await commentAnicon.forward(); // 댓글 들고오기
        await getComments();
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
        setState(() { isBusStWidgetOpen = true;});

        final index = (curBusStop%2)==1 ? curBusStop : curBusStop+1;
        cameras[index].setAnimation(animation: myFly, duration: myDuration);
        await con.updateCamera(cameras[index]);
      }
      else if (busStAnicon.isCompleted) {
        busStAnicon.reverse();
        setState(() { isBusStWidgetOpen = false;});

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

  // 댓글 가져오기
  Future<void> getComments() async {
    setState(() { isLoading = true; isChatModifying = false;});

    final commentDoc =     FIRE.collection('bus_chat').doc(curBusCode);
    final userCollection = FIRE.collection('users');

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

  // 댓글 등록 시 이벤트 처리
  void submitComment(String comment) async {

    // 댓글 문서 가져오기
    final chatDoc = FIRE.collection('bus_chat').doc(curBusCode);

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

    // 마무리
    commentCon.clear();
    try{ FocusScope.of(context).unfocus();} catch(e) {}
  }

  // 애니메이션 초기설정
  void reAnimation() {
    chBusListSizeAni = Tween(begin: 2.5, end: screen.height * 0.50).animate(busStAnicon)  ..addListener(() {setState(() {});});
    chCommentSizeAni = Tween(begin: 0.0, end: screen.height * 0.50).animate(commentAnicon)..addListener(() {setState(() {});});
  }


  Future<bool> onBackPressed() async {
    if (isCommentWidgetOpen) {
      await commentsBoxSlide();
      print('오기는 하냐???');
      return Future.value(false);
    }
    else if (isBusStWidgetOpen) {
      await busStationBoxSlide();
      print('오기는 하냐고');
      return Future.value(false);
    }
    else {
      print('뒤진거냐고');
      return await Navigator.maybePop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    buttons = BUTTON_DATA.map((data) =>
        OutlineCircleButton(
          child: Icon(data.icon, color: white), radius: 50.0, borderSize: 0.5,
          foregroundColor: mainColor, borderColor: white,
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
  void dispose() {
    busStAnicon.dispose();
    commentAnicon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context)..startListeningToUserChanges();
    orientation  = MediaQuery.of(context).orientation;
    screen   = MediaQuery.of(context).size;
    reAnimation();

    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              buildNaverMapWidget(),

              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Column(
                  children: [
                    BusStationWidget(),

                    Container(
                      height: chBusListSizeAni.value - chCommentSizeAni.value,
                      child: BusListWidget(),
                    ),

                    Container(
                      height: chCommentSizeAni.value,
                      child: BusChatListWidget(),
                    ),

                    (isChatModifying) ? SizedBox(width: 0,) : CustomBottomNavigationBar(selectedIndex: 2,),
                  ],
                ),
              ),

              LoadingScreen(limitTime: true, opacity: loadingOpacity, miliTime: 1100,),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNaverMapWidget() {
    return NaverMap(
      options: const NaverMapViewOptions(
        minZoom: 12, maxZoom: 18,
        pickTolerance: 8,
        locale: Locale('kr'),
        mapType: NMapType.basic, liteModeEnable: true,
        initialCameraPosition: GUMI_POS,
        activeLayerGroups: [NLayerGroup.building, NLayerGroup.mountain, NLayerGroup.transit],

        scaleBarEnable: false,
        logoClickEnable: false,
        tiltGesturesEnable: false,
        stopGesturesEnable: false,
        scrollGesturesEnable: true,
        rotationGesturesEnable: false,
      ),

      onMapReady: (NaverMapController controller) async {
        con = controller;

        for (int i = 0; i < 5; i++){
          con.addOverlay(busStopMarks[i]);
          busStopMarks[i].setOnTapListener((overlay) async {
            (isCommentWidgetOpen) ? commentsBoxSlide() : null;
            await busStopMarks[i].openInfoWindow(busStopW[i]);
            await updateBusStop(i);
          });
        }

        await busStopMarks[0].performClick();
      },

      onCameraChange: (reason, animated) async {
        NCameraPosition v = await con.getCameraPosition();
        print('이동한 좌표 : ${v.target.latitude}, ${v.target.longitude}');
        if(reason== NCameraUpdateReason.gesture) {
          setState((){ isMapMoved=true;});
        }
      },

    );
  }

  Widget BusStationWidget () {
    final station = busStopInfos[curBusStop];

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (isBusStWidgetOpen == false && details.delta.dy < 0) { busStationBoxSlide(); }
        if (isBusStWidgetOpen == true  && details.delta.dy > 0) { busStationBoxSlide(); }
      },

      child: Column(
        children: [
          Container(
            width: screen.width * 0.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0),),
              boxShadow: [ BoxShadow(color: mainColor.withOpacity(0.3), spreadRadius: 0, blurRadius: 12, offset: Offset(0, 0)),],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [(isBusStWidgetOpen) ? Icon(Icons.arrow_downward_outlined) : Icon(Icons.arrow_upward_outlined)],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
              boxShadow: [ BoxShadow(color: mainColor.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: Offset(0, -5)),],
            ),

            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 20),
                        Icon(Icons.location_on, color: mainColor, size: 25),
                        SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(station.mainText, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                              SizedBox(height: 14),
                              Text(station.subText,  style: TextStyle(fontSize: 12, color: Colors.grey),),
                              Text('${station.id}',  style: TextStyle(fontSize: 12, color: Colors.grey),),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                  ],
                ),

                Positioned(
                  top: 0, bottom: 0,
                  right: MediaQuery.of(context).size.width * 0.05,
                  child: Center( child: buttons[curButton],),
                ),

                isMapMoved ? Positioned(
                  top: 0, bottom: 0,
                  right: MediaQuery.of(context).size.width * 0.2,
                  child: Center(
                    child: OutlineCircleButton(
                      child: Icon(Icons.undo_outlined, color: white), radius: 50.0, borderSize: 0.5,
                      foregroundColor: mainColor, borderColor: white,
                      onTap: () {
                        final toCurLocationButtonIndex = ((curButton-1) >= 0) ? curButton - 1 : buttons.length - 1;
                        buttons[toCurLocationButtonIndex].onTap();
                      },
                    ),
                  ),
                ) : Container(),

              ],
            )


          ),
        ],
      )


    );

  }

  Widget BusListWidget() {
    ScrollController scrollCon = ScrollController();
    final numOfBus = busList.length;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 2.0,color: const Color(0xFF3F51B5).withOpacity(1.0),),
              bottom: BorderSide(width: 0.5,color: const Color(0xFF3F51B5).withOpacity(0.8),),
            ),
            color: white,
          ),
          height: screen.height / 2,
          child: (isLoading)
            ? Center( child: SizedBox(height: screen.height / 2, child: Center(child: CircularProgressIndicator())))
            : RefreshIndicator(
            color: Colors.white10, displacement: 1000000,
            onRefresh: () async { busStationBoxSlide();},
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              controller: scrollCon,
              itemCount: (numOfBus == 0) ? 1 : numOfBus + 1,
              itemBuilder: (context, index) {

                if (numOfBus == 0) { // 버스 없을 때
                  return SizedBox(
                    height: screen.height / 2,
                    child: Center(child: Text("버스가 없습니다", style: TextStyle(fontSize: 20))),
                  );
                }
                if (index >= numOfBus) { // 마지막 줄
                  return Column(children: [ Divider(), SizedBox(height: 85,),]);
                }

                Bus bus = busList[index];
                final urgentColor = ((bus.arrtime / 60).toInt() >= 5) ? mainColor : Colors.red;
                final busColor = (bus.routetp == '일반버스') ? const Color(0xff05d686) : Colors.purple;

                return GestureDetector(
                  onTap: () async { await callComments(bus.code);},
                  behavior: HitTestBehavior.opaque,
                  child:  Column(
                    children: [
                      (index == 0)
                          ? SizedBox(width: 0,)
                          : Divider(thickness: 1.0,height: 1.0,),
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
                                      Icon(Icons.directions_bus,color: busColor, size: 25),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 2),
                                            Text(
                                              '${bus.routeno}',
                                              style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold),),
                                            SizedBox(height: 10),
                                            Text(
                                              '남은 정류장 : ${bus.arrprevstationcnt}',
                                              style: TextStyle(fontSize: 12,color: Colors.grey),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              '${(bus.arrtime / 60).toInt()}분 ${bus.arrtime % 60}초 후 도착',
                                              style: TextStyle(fontSize: 14,color: urgentColor),
                                            ),
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
                            onPressed: () async { await callComments(bus.code);},
                            icon: Icon(Icons.comment_outlined), //Icons.arrow_circle_up_outlined
                            color: const Color(0xFF3F51B5),
                          ),
                          SizedBox(width: 18,),
                        ],
                      ),
                    ],
                  ),
                );
              },

            ),

          ),
        ),

        (isCommentWidgetOpen) ? Container() :
        Positioned(
          right:  screen.width  * 0.05,
          bottom: screen.height * 0.03,
          child: OutlineCircleButton(
            child: Icon(Icons.refresh, color: white),
            radius: 50.0,borderSize: 0.5,
            foregroundColor: isLoading ? Colors.transparent : mainColor,
            borderColor: white,
            onTap: () async {
              await updateBusListBox();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('업데이트됨'),duration: Duration(milliseconds: 700)),
              );
            },
          ),
        ),
      ],
    );

  }

  Widget BusChatListWidget() {
    commentCon.addListener(onTextChange);
    bool verified = userProvider.isStudentVerified;

    return Container(
      margin:     EdgeInsets.zero,
      decoration: BoxDecoration(
        border:    Border(
          top:      BorderSide(width: 2.0, color: const Color(0xFF3F51B5).withOpacity(0.2),),
          bottom:   BorderSide(width: 0.5, color: const Color(0xFF3F51B5).withOpacity(0.2),),
        ),
      ),

      child: Column(
        children: [

         Expanded(
          child:  Container( // 댓글 출력 창
            decoration: BoxDecoration( color: Colors.white,),
            height:     MediaQuery.of(context).size.height / 2 - ((!isChatModifying) ? 62.5 : 0),

            child: RefreshIndicator(
              displacement: 100000, // 인디케이터 보이지 않도록
              onRefresh:    () async { await commentsBoxSlide();},

              child: (isLoading) ?
              ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2 - 30,
                    child: Center( child: CircularProgressIndicator(),),
                  ),
                ],
              ) : (comments.isEmpty || commentUsers.isEmpty) ?
              ListView(
                children: [
                  Stack(
                    children: [
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: Icon(Icons.arrow_downward),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 2 - 30,
                        child: Center(child: Text("댓글이 없습니다", style: TextStyle(fontSize: 20))),
                      ),
                    ],
                  ),
                ],
              ) : GestureDetector(
                onTap: () {setState(() { isChatModifying = false;}); FocusScope.of(context).unfocus();},
                child: ListView.builder(
                  itemCount:   comments.length,
                  itemBuilder: (context, index) {

                    Comment comment = comments[index]; // 댓글 유저 수 같아야 함.. 탈퇴한 유저? 아직 처리안함
                    UserModel user  = commentUsers[index];

                    if (index == 0) { // 첫째 줄
                      return Container(
                        child: Stack(
                          children: [
                            Container( alignment: Alignment.center, height: 22.0, child: Icon(Icons.arrow_downward,size: 20.0,), ),
                            OneChatWidget( user: user, comment: comment, userProvider: userProvider, updateComment: getComments, tellModifying: modifyingChat),
                          ],),);}

                    else { // 나머지 줄
                      return Container(
                        decoration: BoxDecoration( border: Border(
                            top: BorderSide(width: 1.0, color: Colors.grey.shade200),
                            bottom: (index == comments.length-1) ? BorderSide(width: 1.0, color: Colors.grey.shade200) : BorderSide.none),
                        ), child:   OneChatWidget( user: user, comment: comment, userProvider: userProvider, updateComment: getComments, tellModifying: modifyingChat),
                      );}
                  },
                ),
              ),
            ),
          ),
         ),

          (isChatModifying) ? SizedBox(width: 0,) :
          Container( // 댓글 입력 창
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(width: 1.0, color: const Color(0xFF3F51B5).withOpacity(0.2),),) ),
            height:     60,

            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),

              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller:  commentCon,
                      enabled: verified,
                      decoration:  InputDecoration(
                        filled: true,
                        hintText: verified ? '버스 정보를 공유해주세요!' : '댓글을 작성하려면 학생인증이 필요합니다',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        hintStyle: verified
                            ? (isNoChat ? TextStyle(color: Colors.grey) : TextStyle(color: Colors.black))
                            : TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: (String text) { if (!isNoChat) submitComment(commentCon.text); },
                    ),),

                  SizedBox(width: 5,),

                  Material( // 버튼이 피드백 대처를 위한 공간 마련
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:        () { isNoChat ? null : submitComment(commentCon.text);},
                      borderRadius: BorderRadius.circular(24), // 클릭 피드백 동그라미
                      splashColor:  Color(0xff05d686), // 물결 효과 색상 설정
                      child: Padding(
                        padding: EdgeInsets.all(9.0),
                        child:   Icon(Icons.send, color: isNoChat ? Colors.grey : const Color(0xFF3F51B5)),
                      ),),),

                ],
              ),
            ),
          ),
        ],
      ),
    );

  }

}


// -----------------------------   전역변수   --------------------------------


// 각 버튼에 들어갈 정보 저장
class ButtonData {
  final IconData icon;
  final int nextBusSt;
  final int clickMark;
  ButtonData(this.nextBusSt, this.clickMark, this.icon);
}
List<ButtonData> BUTTON_DATA = [
  ButtonData(1, 2, Icons.school_outlined               ),
  ButtonData(2, 4, Icons.directions_bus_filled_outlined),
  ButtonData(0, 0, Icons.tram_outlined                 ),
];


// 파이어베이스 - 명령어 단축용
final FIRE = FirebaseFirestore.instance;


// 공공데이터 - api 호출주소
const BUS_API_ADDR        = 'http://apis.data.go.kr/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList';
const BUS_API_SERVICE_KEY = 'ZjwvGSfmMbf8POt80DhkPTIG41icas1V0hWkj4cp5RTi1Ruyy2LCU02TN8EJKg0mXS9g2O8B%2BGE6ZLs8VUuo4w%3D%3D';


// 네이버맵 - 정류장 위치
const GUMI_POS     = NCameraPosition(target: NLatLng(36.12882898, 128.3312606), zoom: 15.5, bearing: 0, tilt: 0);
const KUMOH_POS    = NCameraPosition(target: NLatLng(36.14132750, 128.3955675), zoom: 15.5, bearing: 0, tilt: 0);
const TERMINAL_POS = NCameraPosition(target: NLatLng(36.12252942, 128.3510414), zoom: 15.5, bearing: 0, tilt: 0);

// 네이버맵 - 버스리스트 활성화 시 정류장 위치
const GUMI_S_POS    = NCameraPosition(target: NLatLng(36.12502488, 128.3311492), zoom: 15.2, bearing: 0, tilt: 0);
const KUMOH_S_POS   = NCameraPosition(target: NLatLng(36.13280847, 128.3952659), zoom: 14.0, bearing: 0, tilt: 0);
const TERMINAL_S_POS= NCameraPosition(target: NLatLng(36.11941346, 128.3510914), zoom: 15.5, bearing: 0, tilt: 0);


// 네이버맵 - 각 버스정류장 위치에 따른 마커
final busStopMarks = [
  NMarker(position: NLatLng(36.12963461, 128.3293215), id: "구미역",),
  NMarker(position: NLatLng(36.12802335, 128.3331997), id: "농협",),
  NMarker(position: NLatLng(36.14317057, 128.3943957), id: "금오공대종점",),
  NMarker(position: NLatLng(36.13948442, 128.3967393), id: "금오공대입구(옥계중학교방면)",),
  NMarker(position: NLatLng(36.12252942, 128.3510414), id: "종합버스터미널",),
];

// 네이버맵 - 각 마커들을 기반으로 설정한 카메라, 매핑 정보
final cameras = [
  // 구미역, 금오공대, 종합터미널 (버스리스트 미활성화/활성화)
  NCameraUpdate.scrollAndZoomTo(target: GUMI_POS.target,     zoom: GUMI_POS.zoom),
  NCameraUpdate.scrollAndZoomTo(target: GUMI_S_POS.target,     zoom: GUMI_S_POS.zoom),
  NCameraUpdate.scrollAndZoomTo(target: KUMOH_POS.target,    zoom: KUMOH_POS.zoom),
  NCameraUpdate.scrollAndZoomTo(target: KUMOH_S_POS.target,    zoom: KUMOH_S_POS.zoom),
  NCameraUpdate.scrollAndZoomTo(target: TERMINAL_POS.target, zoom: TERMINAL_POS.zoom),
  NCameraUpdate.scrollAndZoomTo(target: TERMINAL_S_POS.target, zoom: TERMINAL_S_POS.zoom)
];
const cameraMap =  [0,2,4]; // 구미역, 금오공대, 종합터미널


// 자주 사용하는 변수들
const NCameraAnimation myFly = NCameraAnimation.fly;
const Duration myDuration    = Duration(milliseconds: 200);
const mainColor = Color(0xFF3F51B5);
const white     = Colors.white;