import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:smart_safe_return/components/home/naver_map/location_marker_widget.dart';
import 'package:smart_safe_return/services/location_service.dart';
import 'package:smart_safe_return/services/permission_service.dart';
import 'package:smart_safe_return/services/tmap_service.dart';

import 'estimated_time_overlay.dart';
import 'naver_map_controller_helper.dart';

class NaverMapWidget extends StatefulWidget {
  const NaverMapWidget({super.key});

  @override
  _NaverMapWidgetState createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends State<NaverMapWidget> {
  NaverMapController? _mapController;
  NLatLng? _currentLocation;
  String? _currentAddress;
  NMarker? _currentMarker;
  NMarker? _clickedMarker;
  String? _clickedAddress;
  NPolylineOverlay? _routePolyline;
  String? _estimatedTime;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!await PermissionService.requestLocationPermission()) return;
    LocationData? locationData = await LocationService.getCurrentLocation();
    if (locationData == null) return;

    final location = NLatLng(locationData.latitude!, locationData.longitude!);
    final address = await TmapService.getAddressFromLatLng(location);

    setState(() {
      _currentLocation = location;
      _currentAddress = address ?? "주소 변환 실패";
    });

    _mapController
        ?.updateCamera(NCameraUpdate.withParams(target: location, zoom: 15));
    await addMarker(
            context, _mapController, location, "current_location", Colors.red,
            refMarker: _currentMarker)
        .then((marker) => _currentMarker = marker);
  }

  Future<void> _onMapTapped(NPoint point, NLatLng position) async {
    final address = await TmapService.getAddressFromLatLng(position);
    await addMarker(
            context, _mapController, position, "clicked_location", Colors.blue,
            refMarker: _clickedMarker)
        .then((marker) => _clickedMarker = marker);
    setState(() => _clickedAddress = address ?? "주소 변환 실패");
  }

  Future<void> _fetchWalkingRoute() async {
    if (_currentLocation == null || _clickedMarker == null) return;

    final start = _currentLocation!;
    final end = _clickedMarker!.position;

    final routePoints = await TmapService.getWalkingRoute(
        start.latitude, start.longitude, end.latitude, end.longitude);
    final seconds = await TmapService.getEstimatedTime(
        start.latitude, start.longitude, end.latitude, end.longitude);

    if (routePoints == null || routePoints.isEmpty) return;

    if (_routePolyline != null) {
      _mapController?.deleteOverlay(_routePolyline!.info);
    }

    _routePolyline = NPolylineOverlay(
      id: "walking_route",
      coords: routePoints,
      color: Colors.blueAccent,
      width: 10,
    );
    _mapController!.addOverlay(_routePolyline!);

    if (seconds != null) {
      final formatted = formatDuration(Duration(seconds: seconds));
      setState(() {
        _estimatedTime = formatted;
      });
    }
  }

  void _adjustEstimatedTime(int minuteDelta) {
    setState(() {
      if (_estimatedTime == null) return;
      _estimatedTime = adjustTimeString(_estimatedTime!, minuteDelta);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: _currentLocation ?? NLatLng(37.5665, 126.9780),
                zoom: 15,
              ),
            ),
            onMapTapped: _onMapTapped,
            onMapReady: (controller) async {
              _mapController = controller;

              if (_currentLocation != null) {
                await addMarker(context, _mapController, _currentLocation!,
                        "current_location", Colors.red)
                    .then((marker) => _currentMarker = marker);
              }

              if (_routePolyline != null) {
                _mapController!.addOverlay(_routePolyline!);
              }
            },
          ),
          LocationMarkerWidget(
            currentAddress: _currentAddress,
            clickedAddress: _clickedAddress,
            onRouteRequest: _fetchWalkingRoute,
            currentLocation: _currentLocation,
            destinationLocation: _clickedMarker?.position,
            routeCoords: _routePolyline?.coords,
            estimatedTime: _estimatedTime,
          ),
          if (_estimatedTime != null)
            EstimatedTimeOverlay(
              estimatedTime: _estimatedTime!,
              onAdd: () => _adjustEstimatedTime(1),
              onRemove: () => _adjustEstimatedTime(-1),
            ),
        ],
      ),
    );
  }
}
