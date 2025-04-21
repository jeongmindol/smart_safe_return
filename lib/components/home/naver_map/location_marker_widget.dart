import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:smart_safe_return/components/home/naver_map/controller/tracking_controls.dart';
import 'package:smart_safe_return/components/home/naver_map/display/address_display.dart';
import 'package:smart_safe_return/services/send_message_log.dart';
import 'package:smart_safe_return/utils/CustomHttpClient.dart';
import 'package:smart_safe_return/services/location_service.dart';
import 'package:smart_safe_return/api/user/emergency_service.dart';
import 'package:smart_safe_return/components/home/naver_map/controller/safe_route_dialog.dart';

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
  bool _isTracking = false;
  bool _isPaused = false;

  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  int? _safeRouteId;
  String? _sosMessage;
  List<String> _phoneList = [];

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

  Future<int?> _sendSafeRouteData() async {
    final prefs = await SharedPreferences.getInstance();
    final memberNumber = prefs.getString('memberNumber');

    if (memberNumber == null) {
      print('❌ memberNumber가 저장되어 있지 않습니다.');
      return null;
    }

    final client = CustomHttpClient();
    final startTime = DateTime.now();

    final rawTime = widget.estimatedTime ?? '';
    final onlyDigits = RegExp(r'\d+').stringMatch(rawTime);
    final minutes = int.tryParse(onlyDigits ?? '0') ?? 0;

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
      'route_path': routePath ?? [],
    };

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final safeRouteId = responseBody['safe_route_id'];
        print('✅ 안전 귀가 경로 전송 성공! safe_route_id: $safeRouteId');

        _startTracking(minutes, safeRouteId);
        return safeRouteId;
      } else {
        print('❌ 전송 실패: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return null;
    }
  }

  void _startTracking(int minutes, int safeRouteId) {
    setState(() {
      _isTracking = true;
      _isPaused = false;
      _remainingTime = Duration(minutes: minutes);
      _safeRouteId = safeRouteId;
    });

    _startTimer();
  }

  void _pauseTracking() {
    _countdownTimer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTracking() {
    setState(() {
      _isPaused = false;
    });
    _startTimer();
  }

  void _cancelTracking() {
    _countdownTimer?.cancel();
    setState(() {
      _isTracking = false;
      _isPaused = false;
      _remainingTime = Duration.zero;
      _isRouteFetched = false;
    });
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isTracking = false;
          _isPaused = false;
        });

        print("🛬 안전 귀가 시간 완료!");

        if (_safeRouteId != null &&
            _sosMessage != null &&
            _phoneList.isNotEmpty) {
          await sendMessageLog(
            safeRouteId: _safeRouteId!,
            message: _sosMessage!,
            phoneList: _phoneList,
          );
        } else {
          print("❌ 메시지 전송에 필요한 데이터가 부족합니다.");
        }
      } else {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes : $seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_isTracking && !_isPaused)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: AddressDisplay(
              title: "현재 위치 : ",
              address: widget.currentAddress ?? "주소를 불러오는 중...",
            ),
          ),
        if (!_isTracking && !_isPaused)
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: AddressDisplay(
              title: "도착 위치 : ",
              address: widget.clickedAddress ?? "지도를 클릭해 위치를 선택하세요",
            ),
          ),
        if (!_isTracking && !_isPaused && widget.estimatedTime != null)
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            child: AddressDisplay(
              title: "예상 도착 시간 : ",
              address: widget.estimatedTime ?? "",
            ),
          ),
        if (_isTracking || _isPaused)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Text(
              "남은 시간: ${_formatDuration(_remainingTime)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        // 버튼 영역
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: !_isTracking && !_isPaused
              ? ElevatedButton(
                  onPressed: widget.clickedAddress != null &&
                          widget.estimatedTime != null
                      ? () async {
                          showSafeRouteDialog(
                            context: context,
                            onConfirm: (selectedContacts, message) {
                              setState(() {
                                _sosMessage = message;
                                _phoneList = selectedContacts
                                    .map<String>((contact) => contact.phone)
                                    .toList();
                              });
                              _sendSafeRouteData();
                            },
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("안전 귀가 시작"),
                )
              : TrackingControls(
                  isPaused: _isPaused,
                  onPause: _pauseTracking,
                  onResume: _resumeTracking,
                  onCancel: _cancelTracking,
                ),
        ),
      ],
    );
  }
}
