import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ✅ 토큰 재발급 함수 (로그인 코드 수정 없이 기존 키까지 지원)
Future<bool> reissueToken() async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken =
      prefs.getString('Refresh') ?? prefs.getString('refreshToken');
  final baseUrl = dotenv.env['API_BASE_URL'];

  if (refreshToken == null || refreshToken.isEmpty) return false;

  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/reissue'),
    headers: {
      'refresh': 'Bearer $refreshToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final newAccess = response.headers['authorization']?.replaceFirst('Bearer ', '');
    final newRefresh = response.headers['refresh']?.replaceFirst('Bearer ', '');

    if (newAccess != null && newRefresh != null) {
      await prefs.setString('Authorization', newAccess);
      await prefs.setString('Refresh', newRefresh);
      // ✅ 기존 로그인 코드 호환용으로도 저장
      await prefs.setString('accessToken', newAccess);
      await prefs.setString('refreshToken', newRefresh);
      return true;
    }
  }

  return false;
}

/// ✅ 공통 GET 요청 함수
Future<http.Response> _authorizedGet(String url) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('Authorization') ?? prefs.getString('accessToken');

  var response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    },
  );

  if (response.statusCode == 401 || response.statusCode == 403) {
    final success = await reissueToken();
    if (success) {
      token = prefs.getString('Authorization') ?? prefs.getString('accessToken');
      response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept-Charset': 'utf-8',
        },
      );
    } else {
      throw Exception("🚨 [GET] 토큰 재발급 실패 → 로그아웃됨");
    }
  }

  return response;
}

/// ✅ 안전길가 기록 조회 Provider
final safeRouteListProvider = FutureProvider.family<List<SafeRoute>, int>((ref, memberNumber) async {
  final baseUrl = dotenv.env['API_BASE_URL'];
  final url = '$baseUrl/api/safe-route/member/$memberNumber';

  final response = await _authorizedGet(url);

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    final sorted = jsonData.reversed.toList();
    return sorted.map((e) => SafeRoute.fromJson(e)).toList();
  } else {
    throw Exception("❌ 안전길가 기록 조회 실패: ${response.statusCode} / ${response.body}");
  }
});

/// ✅ 안전길가 데이터 목록 클래스
class SafeRoute {
  final int safeRouteId;
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final String isSuccess;
  final dynamic routePath;

  SafeRoute({
    required this.safeRouteId,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.isSuccess,
    required this.routePath,
  });

  factory SafeRoute.fromJson(Map<String, dynamic> json) {
    return SafeRoute(
      safeRouteId: json['safe_route_id'],
      startLocation: json['start_location'],
      endLocation: json['end_location'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      isSuccess: json['is_success'],
      routePath: json['route_path'],
    );
  }

  String get formattedDate =>
      "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}";

  String get durationInMinutes =>
      "${endTime.difference(startTime).inMinutes}분";

  String get successStatus =>
      isSuccess == "FAILED" ? "도착 미완료" : "도착 완료";
}
