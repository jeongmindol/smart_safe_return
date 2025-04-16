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

  if (refreshToken != null && accessToken != null) {
    try {
      final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/auth/logout');

      await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'refresh': 'Bearer $refreshToken',
        },
      );
    } catch (_) {
      // 예외 무시
    }
  }

  await prefs.clear();
  ref.read(jwtProvider.notifier).state = {};

  if (context.mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserPage()),
    );
  }
}
