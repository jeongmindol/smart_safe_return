import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ✅ SharedPreferences 초기화
final clearAuthProvider = Provider<Future<void>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
});

/// ✅ 토큰 재발급 함수
Future<bool> reissueToken() async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('Refresh');
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
      return true;
    }
  }

  return false;
}

/// ✅ 공통 GET 요청
Future<http.Response> _authorizedGet(String url) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('Authorization');

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
      token = prefs.getString('Authorization');
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

/// ✅ 공통 PUT 요청
Future<http.Response> _authorizedPut(String url, Map<String, dynamic> body) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('Authorization');

  var response = await http.put(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 401 || response.statusCode == 403) {
    final success = await reissueToken();
    if (success) {
      token = prefs.getString('Authorization');
      response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } else {
      throw Exception("🚨 [PUT] 토큰 재발급 실패 → 로그아웃됨");
    }
  }

  return response;
}

/// ✅ 공통 DELETE 요청
Future<http.Response> _authorizedDelete(String url) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('Authorization');

  var response = await http.delete(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 401 || response.statusCode == 403) {
    final success = await reissueToken();
    if (success) {
      token = prefs.getString('Authorization');
      response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } else {
      throw Exception("🚨 [DELETE] 토큰 재발급 실패 → 로그아웃됨");
    }
  }

  return response;
}

/// ✅ SOS 메시지 내용 조회 Provider
final sosMessageProvider = FutureProvider.family<String, int>((ref, memberNumber) async {
  final baseUrl = dotenv.env['API_BASE_URL'];
  final url = '$baseUrl/api/sos-message/member/$memberNumber';

  final response = await _authorizedGet(url);

  if (response.statusCode == 200) {
    final decodedBody = utf8.decode(response.bodyBytes);
    final data = json.decode(decodedBody);
    return data['content'] ?? '내용이 없습니다';
  } else {
    throw Exception('🚨 메시지 조회 실패: ${response.statusCode} - ${response.body}');
  }
});

/// ✅ SOS 메시지 ID 조회 Provider
final sosMessageIdProvider = FutureProvider.family<int, int>((ref, memberNumber) async {
  final baseUrl = dotenv.env['API_BASE_URL'];
  final url = '$baseUrl/api/sos-message/member/$memberNumber';

  final response = await _authorizedGet(url);

  if (response.statusCode == 200) {
    final decodedBody = utf8.decode(response.bodyBytes);
    final data = json.decode(decodedBody);
    return data['sos_message_id'];
  } else {
    throw Exception('🚨 ID 조회 실패: ${response.statusCode} - ${response.body}');
  }
});

/// ✅ SOS 메시지 수정 Provider
final updateSosMessageProvider = FutureProvider.family<bool, ({int id, String content})>((ref, param) async {
  final baseUrl = dotenv.env['API_BASE_URL'];
  final url = '$baseUrl/api/sos-message/${param.id}';

  final response = await _authorizedPut(url, {
    'sos_message_id': param.id,
    'content': param.content,
  });

  return response.statusCode == 200;
});

/// ✅ SOS 메시지 삭제 Provider (타입 명시적으로 지정)
final deleteSosMessageProvider = Provider<Future<bool> Function(int)>((ref) {
  return (int id) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    final url = '$baseUrl/api/sos-message/$id';

    final response = await _authorizedDelete(url);
    return response.statusCode == 200;
  };
});
