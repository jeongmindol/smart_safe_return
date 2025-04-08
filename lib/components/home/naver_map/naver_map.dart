// //// 민석 ////////

// import 'package:flutter/material.dart';
// import 'package:flutter_naver_map/flutter_naver_map.dart';
// import 'package:location/location.dart';
// import 'package:smart_safe_return/components/home/naver_map/location_marker_widget.dart';
// import 'package:smart_safe_return/services/location_service.dart';
// import 'package:smart_safe_return/services/permission_service.dart';
// import 'package:smart_safe_return/services/tmap_service.dart';

// class NaverMapWidget extends StatefulWidget {
//   const NaverMapWidget({super.key});

//   @override
//   _NaverMapWidgetState createState() => _NaverMapWidgetState();
// }

// class _NaverMapWidgetState extends State<NaverMapWidget> {
//   NaverMapController? _mapController;
//   NLatLng? _currentLocation;
//   String? _currentAddress;
//   NMarker? _currentMarker;
//   NMarker? _clickedMarker;
//   String? _clickedAddress;
//   NPolylineOverlay? _routePolyline;
//   String? _estimatedTime;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     if (!await PermissionService.requestLocationPermission()) return;
//     LocationData? locationData = await LocationService.getCurrentLocation();
//     if (locationData == null) return;

//     NLatLng newLocation =
//         NLatLng(locationData.latitude!, locationData.longitude!);
//     String? address = await TmapService.getAddressFromLatLng(newLocation);

//     setState(() {
//       _currentLocation = newLocation;
//       _currentAddress = address ?? "주소 변환 실패";
//     });

//     _mapController?.updateCamera(
//       NCameraUpdate.withParams(target: newLocation, zoom: 15),
//     );

//     await _addMarker(newLocation, "current_location", Colors.red,
//         refMarker: _currentMarker);
//   }

//   Future<void> _onMapTapped(NPoint point, NLatLng position) async {
//     String? address = await TmapService.getAddressFromLatLng(position);
//     await _addMarker(position, "clicked_location", Colors.blue,
//         refMarker: _clickedMarker);
//     setState(() => _clickedAddress = address ?? "주소 변환 실패");
//   }

//   Future<void> _addMarker(NLatLng position, String id, Color color,
//       {NMarker? refMarker}) async {
//     if (refMarker != null) _mapController?.deleteOverlay(refMarker.info);
//     NMarker newMarker = NMarker(
//       id: id,
//       position: position,
//       icon: await NOverlayImage.fromWidget(
//         context: context,
//         widget: Icon(Icons.location_on, color: color, size: 50),
//         size: const Size(50, 50),
//       ),
//     );
//     _mapController?.addOverlay(newMarker);
//     if (id == "current_location") _currentMarker = newMarker;
//     if (id == "clicked_location") _clickedMarker = newMarker;
//   }

//   Future<void> _fetchWalkingRoute() async {
//     if (_currentLocation == null || _clickedMarker == null) {
//       debugPrint("🚨 출발지 또는 도착지가 설정되지 않았습니다.");
//       return;
//     }

//     double startLat = _currentLocation!.latitude;
//     double startLng = _currentLocation!.longitude;
//     double endLat = _clickedMarker!.position.latitude;
//     double endLng = _clickedMarker!.position.longitude;

//     debugPrint("🟢 길찾기 요청: ($startLat, $startLng) → ($endLat, $endLng)");

//     final List<NLatLng>? routePoints = await TmapService.getWalkingRoute(
//       startLat,
//       startLng,
//       endLat,
//       endLng,
//     );

//     final int? estimatedSeconds = await TmapService.getEstimatedTime(
//       startLat,
//       startLng,
//       endLat,
//       endLng,
//     );

//     if (routePoints == null || routePoints.isEmpty) {
//       debugPrint("⚠️ 경로 데이터를 가져오지 못했습니다.");
//       return;
//     }

//     // 기존 경로 삭제
//     if (_routePolyline != null) {
//       _mapController?.deleteOverlay(_routePolyline!.info);
//     }

//     // 새 경로 추가
//     _routePolyline = NPolylineOverlay(
//       id: "walking_route",
//       coords: routePoints,
//       color: Colors.blueAccent,
//       width: 10,
//     );
//     _mapController!.addOverlay(_routePolyline!);

//     // ⏱ 예상 도착 시간 설정
//     if (estimatedSeconds != null) {
//       final Duration duration = Duration(seconds: estimatedSeconds);
//       final String formattedTime = _formatDuration(duration);
//       setState(() {
//         _estimatedTime = formattedTime;
//       });
//       print(_mapController!.addOverlay(_routePolyline!));

//       debugPrint("⏰ 예상 도착 시간: $formattedTime");
//     } else {
//       debugPrint("🚨 예상 시간 가져오기 실패");
//     }
//   }

//   String _formatDuration(Duration duration) {
//     final int minutes = duration.inMinutes;
//     final int hours = duration.inHours;
//     if (hours > 0) {
//       return "$hours시간 ${minutes % 60}분";
//     } else {
//       return "$minutes분";
//     }
//   }

//   void _adjustEstimatedTime(int minuteDelta) {
//     setState(() {
//       if (_estimatedTime == null) return;

//       int totalMinutes = 0;

//       // 예: "1시간 20분", "30분", "2시간" 등 다양한 형식 처리
//       final hourReg = RegExp(r'(\d+)\s*시간');
//       final minReg = RegExp(r'(\d+)\s*분');

//       final hourMatch = hourReg.firstMatch(_estimatedTime!);
//       final minMatch = minReg.firstMatch(_estimatedTime!);

//       int hours = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;
//       int mins = minMatch != null ? int.parse(minMatch.group(1)!) : 0;

//       totalMinutes = hours * 60 + mins;
//       totalMinutes = (totalMinutes + minuteDelta).clamp(1, 999);

//       final newHours = totalMinutes ~/ 60;
//       final newMins = totalMinutes % 60;

//       _estimatedTime = newHours > 0 ? "$newHours시간 $newMins분" : "$newMins분";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           NaverMap(
//             options: NaverMapViewOptions(
//               initialCameraPosition: NCameraPosition(
//                 target: _currentLocation ?? NLatLng(37.5665, 126.9780),
//                 zoom: 15,
//               ),
//             ),
//             onMapTapped: _onMapTapped,
//             onMapReady: (controller) async {
//               _mapController = controller;

//               // 현재 위치 마커 추가
//               if (_currentLocation != null) {
//                 await _addMarker(
//                     _currentLocation!, "current_location", Colors.red);
//               }

//               // 🚀 지도 준비되었을 때 경로가 있으면 다시 추가
//               if (_routePolyline != null) {
//                 _mapController!.addOverlay(_routePolyline!);
//               }
//             },
//           ),
//           LocationMarkerWidget(
//             currentAddress: _currentAddress,
//             clickedAddress: _clickedAddress,
//             onRouteRequest: _fetchWalkingRoute,
//             isRouteFetched: _clickedMarker != null, // 목적지 선택 여부
//           ),
//           if (_estimatedTime != null)
//             Positioned(
//               top: 150,
//               left: 20,
//               right: 20,
//               child: Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(color: Colors.black26, blurRadius: 5),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // "예상 도착 시간:"
//                     const Text(
//                       "예상 도착 시간:",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     // 시간 텍스트
//                     Text(
//                       _estimatedTime ?? "",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     // ➖ 버튼
//                     IconButton(
//                       icon: const Icon(Icons.remove_circle_outline),
//                       onPressed: () {
//                         _adjustEstimatedTime(-1);
//                       },
//                     ),
//                     // ➕ 버튼
//                     IconButton(
//                       icon: const Icon(Icons.add_circle_outline),
//                       onPressed: () {
//                         _adjustEstimatedTime(1);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }


// / 노일 //////

import 'package:flutter/material.dart';

class NaverMapWidget extends StatelessWidget {
  const NaverMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '지도는 나중에 추가할 예정이에요!',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}