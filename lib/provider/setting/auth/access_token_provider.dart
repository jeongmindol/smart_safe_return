import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔐 Access Token 불러오기 Provider
final accessTokenProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('Authorization');
  if (token == null) {
    throw Exception('Access Token이 없습니다!');
  }
  return token;
});