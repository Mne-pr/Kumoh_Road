import 'dart:convert';
import 'dart:io';
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
  final _putStart = TextEditingController();
  final _putEnd = TextEditingController();
  late NaverMapController con;

  Map<String, String> headerss = {
    "X-NCP-APIGW-API-KEY-ID": "t2v0aiyv0u",
    "X-NCP-APIGW-API-KEY": "R0ydnLxNcjSpxEf6jPt2YQQGE3TCE3UrV84AcSNx"
  };

  @override
  Future<List> get(String url) async {
    http.Response response = await http.get(Uri.parse("https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=$url"), headers: headerss);
    String jsonData = utf8.decode(response.bodyBytes);
    var a = jsonDecode(jsonData)["addresses"][0]['y'];
    var b = jsonDecode(jsonData)["addresses"][0]['x'];
    var d = jsonDecode(jsonData)["addresses"][0]['addressElements'][6]["shortName"];
    List<dynamic> dot = [d, double.parse(a), double.parse(b)];
    return dot;
  }

  void Get_Location() async{
    if(_putStart.text == "" && _putEnd.text == ""){
    }
    List<dynamic> tmp = List.generate(2, (index) => 3, growable:false);
    tmp[0] = await get(_putStart.text);
    tmp[1] = await get(_putEnd.text);
    List<double> start = [tmp[0][1], tmp[0][2]];
    List<double> end = [tmp[1][1], tmp[1][2]];
    final Cpoint = NCameraUpdate.scrollAndZoomTo(target: NLatLng((start[0] + end[0]) / 2, (start[1] + end[1]) / 2), zoom:11.0,);
    await con.updateCamera(Cpoint);
    _putStart.text = tmp[0][0];
    _putEnd.text = tmp[1][0];
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
                onMapReady: (NaverMapController controller) {
                  con = controller;
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
