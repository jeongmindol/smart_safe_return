import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  // 인증 요청 처리
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('Authorization');
    String? refreshToken = prefs.getString('Refresh');

    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    http.StreamedResponse response = await _inner.send(request);

    // 만약 accessToken 만료로 인해 401 에러 발생 시 → 재발급 시도
    if (response.statusCode == 401 && refreshToken != null) {
      print('🔄 액세스토큰 만료, 재발급 시도...');

      final reissueUrl = Uri.parse('https://smart-safe-return-backend-88013499747.asia-northeast2.run.app/api/reissue');
      final reissueResponse = await http.post(
        reissueUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Refresh': 'Bearer $refreshToken',
        },
      );

      if (reissueResponse.statusCode == 200) {
        final newAccessToken = reissueResponse.headers['authorization']?.replaceFirst('Bearer ', '');
        final newRefreshToken = reissueResponse.headers['refresh']?.replaceFirst('Bearer ', '');

        if (newAccessToken != null && newRefreshToken != null) {
          // 새 토큰 저장
          await prefs.setString('Authorization', newAccessToken);
          await prefs.setString('Refresh', newRefreshToken);

          // 원래 요청 재시도
          final retryRequest = http.Request(request.method, request.url)
            ..headers.addAll(request.headers)
            ..body = (request is http.Request) ? request.body : '';

          retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';

          print('✅ 재발급 성공, 요청 재시도...');
          return _inner.send(retryRequest);
        }
      }

      print('❌ 토큰 재발급 실패');
    }

    return response;
  }
}
