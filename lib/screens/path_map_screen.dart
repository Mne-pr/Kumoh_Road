import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kumoh_road/models/main_screen_button_model.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/main_screen_button.dart';

class PathMapScreen extends StatefulWidget {
  const PathMapScreen({Key? key}) : super(key: key);

  @override
  _PathMapScreenState createState() => _PathMapScreenState();
}

class _PathMapScreenState extends State<PathMapScreen> {
  var _putStart = TextEditingController();
  var _putEnd = TextEditingController();

  @override
  void dispose() {
    _putStart.dispose();
    _putEnd.dispose();
    super.dispose();
  }
  void Find_path(){
    print(_putStart.text);
    print(_putEnd.text);
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
                const Text(
                    "출발지 : "
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
                  onPressed: () => Find_path(),
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
                    NLayerGroup.transit
                  ],
                  // 줌 제스쳐만 허용
                  rotationGesturesEnable: true,
                  scrollGesturesEnable: true,
                  tiltGesturesEnable: false,
                  stopGesturesEnable: false,
                  scaleBarEnable: false,
                  logoClickEnable: false,
                ),
                onMapReady: (NaverMapController controller) {
                  // 구미역 앞의 버스정류장 두 곳에 마커 달고, 설명 달음
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
