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
  Future<dynamic> get(String url) async {
    //String base = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=";
    //http.Response response = await http.get(Uri.parse(base + url), headers: headerss);
    http.Response response2 = await http.get(Uri.parse("https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=경상북도 구미시 대학로 61"), headers: headerss);
    String jsonData = response2.body;
    var lon = jsonDecode(jsonData)["addresses"][0]['x'];
    var lat = jsonDecode(jsonData)["addresses"][0]['y'];
    List<String> geo = [lon, lat];
    return geo;
  }
  var _putStart = TextEditingController();
  var _putEnd = TextEditingController();

  @override
  void dispose() {
    _putStart.dispose();
    _putEnd.dispose();
    super.dispose();
  }
  void Get_Location(){
    var tmp = get(_putStart.text);
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Positioned(
                  left: 0,
                  top: 0,
                  child: SizedBox(
                    width: 50,
                    height: 30,
                    child: Text(
                      '출발지 : ',
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _putStart,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Text(
                  "도착지 : "
                ),
                Expanded(
                  child: TextField(
                    controller: _putEnd,
                  ),
                ),
              ],
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
