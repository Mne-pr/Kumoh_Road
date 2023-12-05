import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../widgets/bottom_navigation_bar.dart';
import 'translate_address_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "package:http/http.dart" as http;
import "package:geolocator/geolocator.dart";

class PathMapScreen extends StatefulWidget {
  const PathMapScreen({Key? key}) : super(key: key);

  @override

  _PathMapScreenState createState() => _PathMapScreenState();
}

class _PathMapScreenState extends State<PathMapScreen> {
  //design 변수
  double marginSize = 15;
  FocusNode originTextFocus = FocusNode();
  FocusNode destinationTextFocus = FocusNode();

  //text 변수
  final originAddress = TextEditingController();
  final destinationAddress = TextEditingController();
  late NaverMapController mapController;
  Map<String, String> nmapID = {"X-NCP-APIGW-API-KEY-ID": "t2v0aiyv0u", "X-NCP-APIGW-API-KEY": "R0ydnLxNcjSpxEf6jPt2YQQGE3TCE3UrV84AcSNx"};
  List<String> inputString = List.filled(2, "");
  List<dynamic> coordinateList = List.generate(2, (index) => 5, growable: false); //구조[응답상태, 응답 데이터 수, 이름, 위도, 경도]
  List<dynamic> markerList = List.generate(2, (index) => null, growable: false);

  //주소 입력 오류 출력 Toast
  void errorView(String errorMessage) {
    Fluttertoast.showToast(
      msg: errorMessage,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      fontSize: 20.0,
      textColor: Colors.black,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void getMYPosition() async{
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    try{
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double tmp1 = position.latitude;
      double tmp2 = position.longitude;
      print("$tmp1 $tmp2");
    }catch(e){
      print(e);
    }
  }

  Future<List> getCoordinate(String pointAddress) async {
    http.Response response =
        await http.get(Uri.parse("https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=$pointAddress"), headers: nmapID);
    if (response.statusCode == 200) {
      String jsonData = utf8.decode(response.bodyBytes);
      int checkResponse = jsonDecode(jsonData)["meta"]["totalCount"];
      if (checkResponse >= 1) {
        String pointName = jsonDecode(jsonData)["addresses"][0]["addressElements"][6]["shortName"];
        double pointLat = double.parse(jsonDecode(jsonData)["addresses"][0]["y"]);
        double pointLon = double.parse(jsonDecode(jsonData)["addresses"][0]["x"]);
        List<dynamic> tempList = [response.statusCode, checkResponse, pointName, pointLat, pointLon];
        return tempList;
      } else {
        List<dynamic> tempList = [response.statusCode, checkResponse, 0, 0, 0];
        return tempList;
      }
    } else {
      List<dynamic> tempList = [response.statusCode, -1, 0, 0, 0];
      return tempList;
    }
  }

  Future<List> getPath() async {
    http.Response response = await http.get(
        Uri.parse(
            "https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=${coordinateList[0][4]},${coordinateList[0][3]}&goal=${coordinateList[1][4]},${coordinateList[1][3]}&option={탐색옵션}"),
        headers: nmapID);
    String jsonData = utf8.decode(response.bodyBytes);
    List<dynamic> tempList = jsonDecode(jsonData)["route"]["traoptimal"][0]["path"];
    List<dynamic> tcoordList = List.generate(tempList.length, (index) => null, growable: false);
    for (int i = 0; i < tempList.length; i++) {
      tcoordList[i] = NLatLng(tempList[i][1], tempList[i][0]);
    }
    return tcoordList;
  }

  void moveMap() async {
    final movePoint = NCameraUpdate.scrollAndZoomTo(
      target: NLatLng((coordinateList[0][3] + coordinateList[1][3]) / 2 - 0.01, (coordinateList[0][4] + coordinateList[1][4]) / 2),
      zoom: 11.5,
    );
    markerList[0] = NMarker(id: coordinateList[0][2], position: NLatLng(coordinateList[0][3], coordinateList[0][4]), icon:const NOverlayImage.fromAssetImage('assets/images/main_marker.png'));
    markerList[1] = NMarker(id: coordinateList[1][2], position: NLatLng(coordinateList[1][3], coordinateList[1][4]), icon:const NOverlayImage.fromAssetImage('assets/images/main_marker.png'));
    List<dynamic> tempList = await getPath();
    List<NLatLng> pathCoordinate = List.generate(tempList.length, (index) => const NLatLng(0.0, 0.0));
    for (int i = 0; i < tempList.length; i++) {
      pathCoordinate[i] = tempList[i];
    }
    final tempLine = NPolylineOverlay(id: "path", coords: pathCoordinate, color: const Color(0xffff0000), width: 5);
    await mapController.clearOverlays();
    await mapController.updateCamera(movePoint);
    await mapController.addOverlayAll({markerList[0], markerList[1], tempLine});
  }

  void mapSet() async {
    if (originAddress.text == "" || destinationAddress.text == "") {
      errorView("주소 입력란이 비어있습니다");
    } else {
      if (inputString[0] != originAddress.text) {
        inputString[0] = originAddress.text;
        coordinateList[0] = await getCoordinate(inputString[0]);
        print("출발지 API 호출함");
      }
      if (inputString[1] != destinationAddress.text) {
        inputString[1] = destinationAddress.text;
        coordinateList[1] = await getCoordinate(inputString[1]);
        print("도착지 API 호출함");
      }
      if (coordinateList[0][0] == 200 && coordinateList[1][0] == 200) {
        if (coordinateList[0][1] == 0 && coordinateList[1][1] == 0) {
          errorView("잘못된 주소입니다");
          originTextFocus.requestFocus();
        } else if (coordinateList[0][1] == 0) {
          errorView("잘못된 출발지 주소입니다");
          originTextFocus.requestFocus();
        } else if (coordinateList[1][1] == 0) {
          errorView("잘못된 도착지 주소입니다");
          destinationTextFocus.requestFocus();
        } else {
          print(coordinateList);
          moveMap();
        }
      } else {
        errorView("Error:response is Not 200");
      }
    }
  }

  @override
  void dispose(){
    originAddress.dispose();
    originTextFocus.dispose();
    destinationAddress.dispose();
    destinationTextFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getMYPosition();
    const basePosition = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            NaverMap(
              options: const NaverMapViewOptions(
                minZoom: 6,
                maxZoom: 18,
                pickTolerance: 8,
                locale: Locale('kr'),
                mapType: NMapType.basic,
                liteModeEnable: true,
                initialCameraPosition: basePosition,
                activeLayerGroups: [
                  NLayerGroup.building,
                  NLayerGroup.mountain,
                  NLayerGroup.bicycle,
                ],
                rotationGesturesEnable: false,
                scrollGesturesEnable: true,
                tiltGesturesEnable: false,
                stopGesturesEnable: false,
                scaleBarEnable: false,
                logoClickEnable: false,
              ),
              onMapReady: (NaverMapController controller) {
                mapController = controller;
              },
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 150,
                color: const Color(0xd0ffffff),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(marginSize, marginSize, marginSize, 5),
                      height: 35,
                      child: SizedBox(
                        width: (MediaQuery.of(context).size.width - marginSize * 2),
                        height: 35,
                        child: TextField(
                          controller: originAddress,
                          focusNode: originTextFocus,
                          textAlignVertical: TextAlignVertical.bottom,
                          textAlign: TextAlign.left,
                          onSubmitted: (text) {},
                          onTap: () async {
                            final getAddress = await Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const TranslateAddressScreen()),
                            );
                            if(getAddress != null){
                              originAddress.text = getAddress as String;
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "출발지를 입력하세요",
                            filled: true,
                            fillColor: Color(0xffdddddd),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black54,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(marginSize, 5, marginSize, 5),
                      height: 35,
                      child: SizedBox(
                        width: (MediaQuery.of(context).size.width - marginSize * 2),
                        height: 35,
                        child: TextField(
                          controller: destinationAddress,
                          focusNode: destinationTextFocus,
                          textAlignVertical: TextAlignVertical.bottom,
                          textAlign: TextAlign.left,
                          onSubmitted: (text) {},
                          onTap: () async {
                            final getAddress = await Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const TranslateAddressScreen()),
                            );
                            if(getAddress != null){
                              destinationAddress.text = getAddress as String;
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "도착지를 입력하세요",
                            filled: true,
                            fillColor: Color(0xffdddddd),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black54,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.3, 5, MediaQuery.of(context).size.width * 0.3, 0),
                      child: SizedBox(
                        width: (MediaQuery.of(context).size.width - marginSize * 2),
                        height: 35,
                        child: TextButton(
                          onPressed: () => {
                            originTextFocus.unfocus(),
                            destinationTextFocus.unfocus(),
                            mapSet(),
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(5),
                            backgroundColor: const Color(0xFF3F51B5),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          child: const Text('경로 탐색'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 3,
      ),
    );
  }
}
