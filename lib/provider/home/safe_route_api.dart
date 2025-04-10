import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> sendSafeRouteData({
  required String startLocation,
  required String endLocation,
  required DateTime startTime,
  required List<Map<String, dynamic>> routePath,
  Duration estimatedDuration = const Duration(minutes: 20),
}) async {
  final prefs = await SharedPreferences.getInstance();
  final memberNumber = prefs.getString('memberNumber');

  if (memberNumber == null) {
    print('❌ memberNumber가 저장되어 있지 않습니다.');
    return;
  }

  final endTime = startTime.add(estimatedDuration);

  final url = Uri.parse('${dotenv.env['API_BASE_URL']}/api/safe-route');

  final body = {
    'member_number': memberNumber,
    'start_location': startLocation,
    'end_location': endLocation,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'route_path': routePath,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('✅ 안전 귀가 경로 전송 성공!');
    } else {
      print('❌ 전송 실패: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('❌ 예외 발생: $e');
  }
}
