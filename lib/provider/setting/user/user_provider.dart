import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final jwtProvider = StateProvider<Map<String, String?>>((ref) => {});

/// ✅ 앱 시작 시 자동 로그인 체크
Future<void> checkAutoLogin(WidgetRef ref, BuildContext context) async {
  print('🟡 checkAutoLogin 실행됨!');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('Authorization');
  final refresh = prefs.getString('Refresh');
  final id = prefs.getString('id');
  final memberNumber = prefs.getString('memberNumber');

  print('🔍 저장된 token: $token');
  print('🔍 저장된 id: $id');

  if (token != null && !JwtDecoder.isExpired(token)) {
    ref.read(jwtProvider.notifier).state = {
      'Authorization': token,
      'Refresh': refresh,
      'id': id,
      'memberNumber': memberNumber,
    };

    print('✅ 자동 로그인 성공! jwtProvider 상태: ${ref.read(jwtProvider)}');
  } else {
    print('❌ 자동 로그인 실패: 토큰이 없거나 만료됨');
  }
}

/// ✅ 로그인 시도 함수
Future<bool> login(WidgetRef ref, String id, String password) async {
  final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/auth/login',
  );

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'id': id, 'password': password}),
  );

  print('응답 상태 코드: ${response.statusCode}');
  print('응답 헤더: ${response.headers}');

  if (response.statusCode == 200) {
    final accessToken = response.headers['authorization']?.replaceFirst('Bearer ', '');
    final refreshToken = response.headers['refresh']?.replaceFirst('Bearer ', '');

    if (accessToken != null && refreshToken != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        String memberNumber = decodedToken['memberNumber'].toString();
        String id = decodedToken['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('Authorization', accessToken);
        await prefs.setString('Refresh', refreshToken);
        await prefs.setString('id', id);
        await prefs.setString('memberNumber', memberNumber);

        ref.read(jwtProvider.notifier).state = {
          'Authorization': accessToken,
          'Refresh': refreshToken,
          'id': id,
          'memberNumber': memberNumber,
        };

        print('✅ 로그인 성공! jwtProvider 상태: ${ref.read(jwtProvider)}');

        return true;
      } catch (e) {
        print('❌ 토큰 디코딩 오류: $e');
        return false;
      }
    } else {
      print("❌ 헤더에 토큰이 없습니다.");
      return false;
    }
  }

  return false;
}
