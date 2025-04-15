import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MySafeguardPostProvider {
  final String apiUrl = "${dotenv.env['API_BASE_URL']}/api/emergency-contact";
  final String reissueUrl = "${dotenv.env['API_BASE_URL']}/api/reissue";

  Future<bool> registerGuardian({
    required int memberNumber,
    required String name,
    required String phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('Authorization');

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('AccessToken 없음');
      }

      var response = await _postRequest(accessToken, memberNumber, name, phone);

      if (response.statusCode == 403) {
        // 🔁 AccessToken 재발급 시도
        final refreshToken = prefs.getString('Refresh');
        if (refreshToken == null || refreshToken.isEmpty) {
          throw Exception('RefreshToken 없음');
        }

        final reissueResponse = await http.post(
          Uri.parse(reissueUrl),
          headers: {'Authorization': 'Bearer $refreshToken'},
        );

        if (reissueResponse.statusCode == 200) {
          final tokenData = jsonDecode(reissueResponse.body);
          final newAccessToken = tokenData['accessToken'];
          final newRefreshToken = tokenData['refreshToken'];

          await prefs.setString('Authorization', newAccessToken);
          await prefs.setString('Refresh', newRefreshToken);

          response = await _postRequest(newAccessToken, memberNumber, name, phone);
        } else {
          throw Exception('토큰 재발급 실패');
        }
      }

      if (response.statusCode == 200) {
        debugPrint("✅ 등록 성공!");
        return true;
      } else {
        debugPrint("❌ 등록 실패: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ 등록 중 오류: $e");
      return false;
    }
  }

  /// ✅ 내부 POST 요청
  Future<http.Response> _postRequest(
      String token, int memberNumber, String name, String phone) {
    return http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'member_number': memberNumber,
        'name': name,
        'phone': phone,
      }),
    );
  }
}
