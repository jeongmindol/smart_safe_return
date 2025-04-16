import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

/// ✅ 공통 POST 요청 (토큰 재발급 포함)
Future<http.Response> _authorizedPost(String url, Map<String, dynamic> body) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('Authorization');

  var response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 401 || response.statusCode == 403) {
    final success = await _reissueToken();
    if (success) {
      token = prefs.getString('Authorization');
      response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } else {
      throw Exception("🚨 [POST] 토큰 재발급 실패 → 로그아웃됨");
    }
  }

  return response;
}

/// ✅ 토큰 재발급 함수
Future<bool> _reissueToken() async {
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

/// ✅ Provider 선언
final postSosMessageProvider = Provider((ref) => SosMessagePoster());

/// ✅ SOS 메시지 등록 처리
class SosMessagePoster {
  final String apiUrl = '${dotenv.env['API_BASE_URL']}/api/sos-message';

  Future<void> postSosMessage({
    required BuildContext context,
    required int memberNumber,
    required String content,
      VoidCallback? onSuccess, // ✅ 추가
      VoidCallback? onDuplicate, // ✅ 추가
  }) async {
    try {
      final response = await _authorizedPost(apiUrl, {
        'member_number': memberNumber,
        'content': content,
      });

      if (response.statusCode == 200) {
        showPopup(context, '메세지 등록이 완료되었습니다.');
        onSuccess?.call(); // ✅ 성공 시 콜백 실행
      } else {
        final decoded = utf8.decode(response.bodyBytes);
        print('🔴 [SOS 등록 실패 응답]: $decoded');

        if (decoded.toLowerCase().contains('duplicate sosmessage')) {
          showPopup(context, '이미 등록된 메세지가 있습니다.');
          onDuplicate?.call(); // ✅ 중복 시 입력창 초기화
        } else {
          showPopup(context, '등록에 실패했습니다.\n$decoded');
        }
      }
    } catch (e) {
      print('🧨 [postSosMessage 오류] $e');
      showPopup(context, '요청 중 오류가 발생했습니다.\n$e');
    }
  }
}
