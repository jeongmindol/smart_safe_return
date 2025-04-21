import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_safe_return/utils/CustomHttpClient.dart';
import 'package:smart_safe_return/services/location_service.dart';
import 'package:location/location.dart';

Future<void> sendMessageLog({
  required int safeRouteId,
  required String message,
  required List<String> phoneList,
}) async {
  final locationData = await LocationService.getCurrentLocation();

  if (locationData == null) {
    print('❌ 위치 정보를 가져올 수 없습니다.');
    return;
  }

  final coordinates = [
    locationData.longitude ?? 0.0,
    locationData.latitude ?? 0.0,
  ];

  final body = {
    "safe_route_id": safeRouteId,
    "message": message,
    "location": {
      "type": "Point",
      "coordinates": coordinates,
    },
    "phone_list": phoneList,
  };

  final client = CustomHttpClient();
  final url = Uri.parse('${dotenv.env['API_BASE_URL']}/api/message-log');

  try {
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ 메시지 로그 전송 성공');
    } else {
      print('❌ 메시지 로그 전송 실패: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('🚨 메시지 로그 전송 중 예외 발생: $e');
  }
}
