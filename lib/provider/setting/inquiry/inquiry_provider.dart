import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ✅ 토큰 재발급
Future<bool> reissueToken() async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('Refresh') ?? prefs.getString('refreshToken');
  final baseUrl = dotenv.env['API_BASE_URL'];

  if (refreshToken == null || refreshToken.isEmpty) return false;

  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/reissue'),
    headers: {
      'Refresh': 'Bearer $refreshToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final newAccess = response.headers['authorization']?.replaceFirst('Bearer ', '') ??
        response.headers['Authorization']?.replaceFirst('Bearer ', '');
    final newRefresh = response.headers['refresh']?.replaceFirst('Bearer ', '') ??
        response.headers['Refresh']?.replaceFirst('Bearer ', '');

    if (newAccess != null && newRefresh != null) {
      await prefs.setString('Authorization', newAccess);
      await prefs.setString('Refresh', newRefresh);
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
      throw Exception("토큰 재발급 실패 → 로그아웃됨");
    }
  }

  return response;
}

/// ✅ 공통 PUT 요청 함수
Future<http.Response> _authorizedPut(String url, Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('Authorization') ?? prefs.getString('accessToken');

  var response = await http.put(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    },
    body: jsonEncode(data),
  );

  return response;
}

/// ✅ 문의 모델 정의
class InquiryQuestion {
  final int questionId;
  final String title;
  final String content;
  final String categoryName;
  final String status;
  final String createdDate;
  final String? modifiedDate;

  InquiryQuestion({
    required this.questionId,
    required this.title,
    required this.content,
    required this.categoryName,
    required this.status,
    required this.createdDate,
    this.modifiedDate,
  });

  factory InquiryQuestion.fromJson(Map<String, dynamic> json) {
    return InquiryQuestion(
      questionId: json['question_id'],
      title: json['title'],
      content: json['content'],
      categoryName: json['category'],
      status: json['status'],
      createdDate: json['created_date'],
      modifiedDate: json['modified_date'],
    );
  }

  String get formattedDate {
    final date = modifiedDate ?? createdDate;
    final DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.year}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.day.toString().padLeft(2, '0')}";
  }
}

/// ✅ 사용자 문의 목록 Provider
final inquiryListProvider = FutureProvider.family<List<InquiryQuestion>, int>((ref, memberNumber) async {
  final baseUrl = dotenv.env['API_BASE_URL'];
  final url = '$baseUrl/api/question/member/$memberNumber';

  final response = await _authorizedGet(url);

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    final sorted = jsonData.reversed.toList();
    return sorted.map((e) => InquiryQuestion.fromJson(e as Map<String, dynamic>)).toList();
  } else {
    throw Exception("문의 리스트 불러오기 실패: ${response.statusCode} / ${response.body}");
  }
});

/// ✅ 문의 수정 요청 Provider
final updateInquiryProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  final baseUrl = dotenv.env['API_BASE_URL'];
  final questionId = params['questionId'] ?? params['question_id'];

  final data = {
    'question_id': questionId,
    'title': params['title'],
    'content': params['content'],
    'category': params['category'],
  };

  final url = '$baseUrl/api/question/$questionId';

  final response = await _authorizedPut(url, data);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception("문의 수정 실패: ${response.statusCode} / ${response.body}");
  }
});

/// ✅ 공통 DELETE 요청 함수
Future<http.Response> _authorizedDelete(String url) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('Authorization') ?? prefs.getString('accessToken');

  var response = await http.delete(
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
      response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept-Charset': 'utf-8',
        },
      );
    } else {
      throw Exception("토큰 재발급 실패 → 로그아웃됨");
    }
  }

  return response;
}

/// ✅ 삭제 Provider
final deleteInquiryProvider = FutureProvider.family<bool, int>((ref, questionId) async {
  final baseUrl = dotenv.env['API_BASE_URL'];
  final url = '$baseUrl/api/question/$questionId';

  final response = await _authorizedDelete(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception("문의 삭제 실패: ${response.statusCode} / ${response.body}");
  }
});
