import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class LocationMarkerWidget extends StatefulWidget {
  final String? currentAddress;
  final String? clickedAddress;
  final VoidCallback? onRouteRequest;
  final NLatLng? currentLocation;
  final NLatLng? destinationLocation;
  final List<NLatLng>? routeCoords;
  final String? estimatedTime;

  const LocationMarkerWidget({
    super.key,
    this.currentAddress,
    this.clickedAddress,
    this.onRouteRequest,
    this.currentLocation,
    this.destinationLocation,
    this.routeCoords,
    this.estimatedTime,
  });

  @override
  State<LocationMarkerWidget> createState() => _LocationMarkerWidgetState();
}

class _LocationMarkerWidgetState extends State<LocationMarkerWidget> {
  bool _isRouteFetched = false;

  @override
  void didUpdateWidget(covariant LocationMarkerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.clickedAddress != null &&
        widget.clickedAddress != oldWidget.clickedAddress) {
      widget.onRouteRequest?.call();

      setState(() {
        _isRouteFetched = true;
      });
    }
  }

  Future<void> _sendSafeRouteData() async {
    final prefs = await SharedPreferences.getInstance();
    final memberNumber = prefs.getString('memberNumber');

    if (memberNumber == null) {
      print('❌ memberNumber가 저장되어 있지 않습니다.');
      return;
    }

    final startTime = DateTime.now();
    final minutes = int.tryParse(widget.estimatedTime ?? '') ?? 0;
    final endTime = startTime.add(Duration(minutes: minutes));

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/api/safe-route');

    final routePath = widget.routeCoords
        ?.map((coord) => {
              "lat": coord.latitude,
              "lng": coord.longitude,
            })
        .toList();

    final body = {
      'member_number': memberNumber,
      'start_location': widget.currentAddress ?? '',
      'end_location': widget.clickedAddress ?? '',
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      // 'estimated_time': widget.estimatedTime ?? '',
      'route_path': routePath ?? [],
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print(body);

      if (response.statusCode == 200) {
        print('✅ 안전 귀가 경로 전송 성공!');
      } else {
        print('❌ 전송 실패: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: _buildAddressContainer(
            "현재 위치 : ",
            widget.currentAddress ?? "주소를 불러오는 중...",
          ),
        ),
        Positioned(
          top: 100,
          left: 20,
          right: 20,
          child: _buildAddressContainer(
            "도착 위치 : ",
            widget.clickedAddress ?? "지도를 클릭해 위치를 선택하세요",
          ),
        ),
        Positioned(
          bottom: 30,
          left: 50,
          right: 50,
          child: ElevatedButton(
            onPressed: _isRouteFetched ? _sendSafeRouteData : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRouteFetched ? Colors.blue : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "안전 귀가 시작",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressContainer(String title, String address) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Text(
        "$title $address",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
