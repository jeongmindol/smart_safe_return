// lib/provider/setting/inquiry/inquiry_post_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';
import 'package:smart_safe_return/components/setting/inquiry/inquiry.dart';

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

final postInquiryProvider = Provider((ref) => InquiryPoster());

class InquiryPoster {
  final String apiUrl = '${dotenv.env['API_BASE_URL']}/api/question';

  Future<void> postInquiry({
    required BuildContext context,
    required String title,
    required String category,
    required String content,
    required int memberNumber,
    VoidCallback? onSuccess,
  }) async {
    try {
      final response = await _authorizedPost(apiUrl, {
        'member_number': memberNumber,
        'title': title,
        'category': category,
        'content': content,
      });

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (popupContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('문의 등록', textAlign: TextAlign.center),
            content: const Text('등록이 완료되었습니다.', textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(popupContext).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Inquiry()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        onSuccess?.call();
      } else {
        final decoded = utf8.decode(response.bodyBytes);
        showPopup(context, '등록 실패: $decoded');
      }
    } catch (e) {
      showPopup(context, '요청 실패: $e');
    }
  }
}