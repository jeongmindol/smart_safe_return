// lib/provider/setting/user/mypageinfo_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_safe_return/components/setting/user/user.dart';
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> handleLogout(BuildContext context, WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('Refresh');
  final accessToken = prefs.getString('Authorization');

  // 백엔드 로그아웃 요청
  if (refreshToken != null && accessToken != null) {
    try {
      final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/auth/logout',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'refresh': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        print('✅ 백엔드 로그아웃 성공');
      } else {
        print('❌ 백엔드 로그아웃 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 로그아웃 중 오류 발생: $e');
    }
  } else {
    print('⚠️ 토큰이 존재하지 않아 로그아웃 요청 생략됨');
  }

  // 프론트 상태 초기화
  await prefs.clear(); // 모든 저장된 토큰/정보 제거
  ref.read(jwtProvider.notifier).state = {};

  // 로그인 페이지로 이동
  if (context.mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserPage()),
    );
  }
}
