import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../utilities/bike_util.dart';

class PreviewLocation extends StatefulWidget {
  final Point loadAddress;

  const PreviewLocation(this.loadAddress, {super.key});

  @override
  _PreviewLocationState createState() => _PreviewLocationState();
}

class _PreviewLocationState extends State<PreviewLocation> {
  @override
  Widget build(BuildContext context) {
    const basePosition = NCameraPosition(target: NLatLng(36.12827222, 128.3310162), zoom: 15.5, bearing: 0, tilt: 0);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            NaverMap(
              options: const NaverMapViewOptions(
                minZoom: 12,
                maxZoom: 16,
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
                scrollGesturesEnable: false,
                tiltGesturesEnable: false,
                stopGesturesEnable: false,
                scaleBarEnable: false,
                logoClickEnable: false,
              ),
              onMapReady: (NaverMapController controller) async {
                await controller.updateCamera(
                  NCameraUpdate.scrollAndZoomTo(
                    target: NLatLng(widget.loadAddress.lat, widget.loadAddress.lon),
                    zoom: 14,
                  ),
                );
                final marker = NMarker(
                  id: widget.loadAddress.name,
                  position: NLatLng(widget.loadAddress.lat, widget.loadAddress.lon),
                  icon: const NOverlayImage.fromAssetImage('assets/images/main_marker.png'),
                );
                final markerInfo = NInfoWindow.onMarker(id: marker.info.id, text: marker.info.id);
                controller.addOverlay(marker);
                marker.openInfoWindow(markerInfo);
              },
            ),
          ],
        ),
      ),
    );
  }
}
