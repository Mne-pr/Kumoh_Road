import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../widgets/bottom_navigation_bar.dart';
import "package:http/http.dart" as http;

class PathMapScreen extends StatefulWidget {
  const PathMapScreen({Key? key}) : super(key: key);

  @override
  _PathMapScreenState createState() => _PathMapScreenState();
}

class _PathMapScreenState extends State<PathMapScreen> {
  //장소 이름을 좌표로 변경하기 위한 api id
  Map<String, String> headerss = {
    "X-NCP-APIGW-API-KEY-ID": "t2v0aiyv0u",
    "X-NCP-APIGW-API-KEY": "R0ydnLxNcjSpxEf6jPt2YQQGE3TCE3UrV84AcSNx"
  };
  //장소를 좌표로 변경하는 api

  var _putStart = TextEditingController();
  var _putEnd = TextEditingController();

  @override
  //좌표 변환 코드
  Future<List> get(String url) async {
    http.Response response2 = await http.get(Uri.parse("https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=$url"), headers: headerss);
    String jsonData = utf8.decode(response2.bodyBytes);
    var a = jsonDecode(jsonData)["addresses"][0]['x'];
    var b = jsonDecode(jsonData)["addresses"][0]['y'];
    List<dynamic> dot = [double.parse(a), double.parse(b)];
    return dot;
  }

  void Get_Location() async{
    List<dynamic> tmp = List.generate(3, (index) => 2, growable:false);
    tmp[0] = await get(_putStart.text);
    tmp[1] = await get(_putEnd.text);
    print(tmp[0]);
    print(tmp[1]);
    final controller = NCameraUpdate.scrollAndZoomTo(target: NLatLng(tmp[0][1], tmp[0][0]));
  }

  void dispose() {
    _putStart.dispose();
    _putEnd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Baseposition = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
              height: 35,
              child: TextField(
                controller: _putStart,
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  hintText: "출발지를 입력하세요",
                  filled: true,
                  fillColor: Colors.black12,
                  enabledBorder:
                  OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              height: 35,
              child: TextField(
                controller: _putEnd,
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  hintText: "도착지를 입력하세요",
                  filled: true,
                  fillColor: Colors.black12,
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get_Location(),
              child: const Text('경로 탐색'),
            ),
            Expanded(
              child: NaverMap(
                options: const NaverMapViewOptions(
                  minZoom: 12,
                  maxZoom: 18,
                  pickTolerance: 8,
                  locale: Locale('kr'),
                  mapType: NMapType.basic,
                  liteModeEnable: true,
                  initialCameraPosition: Baseposition,
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
                onMapReady: (final NaverMapController controller) {
                },
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
