import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MySafeguardListProvider {
  final String apiUrl = "${dotenv.env['API_BASE_URL']}/api/emergency-contact";
  final String reissueUrl = "${dotenv.env['API_BASE_URL']}/api/reissue";

  /// 평가 목록 가져오기
  Future<List<Map<String, String>>> fetchGuardians(int memberNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('Authorization');
      if (token == null || token.isEmpty) {
        throw Exception('토큰이 없습니다');
      }

      var response = await _getRequest(token, memberNumber);

      if (response.statusCode == 403) {
        final newToken = await _refreshToken();
        if (newToken != null) {
          response = await _getRequest(newToken, memberNumber);
        } else {
          throw Exception('토큰 재발급 실패');
        }
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map<Map<String, String>>((item) {
          return {
            'id': item['emergency_contact_id'].toString(),
            'name': item['name'] ?? '',
            'phone': item['phone'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('안전지킴이 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 수정
  Future<void> updateGuardian(int id, String name, String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('Authorization');
      if (token == null || token.isEmpty) {
        throw Exception('토큰이 없습니다');
      }

      var response = await _putRequest(token, id, name, phone);

      if (response.statusCode == 403) {
        final newToken = await _refreshToken();
        if (newToken != null) {
          response = await _putRequest(newToken, id, name, phone);
        } else {
          throw Exception('토큰 재발급 실패');
        }
      }

      if (response.statusCode != 200) {
        throw Exception('수정 실패 (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('수정 중 오류 발생: $e');
    }
  }

  /// 삭제
  Future<void> deleteGuardian(int emergencyContactId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('Authorization');
      if (token == null || token.isEmpty) {
        throw Exception('토큰이 없습니다');
      }

      var response = await _deleteRequest(token, emergencyContactId);

      if (response.statusCode == 403) {
        final newToken = await _refreshToken();
        if (newToken != null) {
          response = await _deleteRequest(newToken, emergencyContactId);
        } else {
          throw Exception('토큰 재발급 실패');
        }
      }

      if (response.statusCode != 200) {
        throw Exception('삭제 실패 (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('삭제 중 오류 발생: $e');
    }
  }

  Future<http.Response> _getRequest(String token, int memberNumber) {
    return http.get(
      Uri.parse('$apiUrl/member/$memberNumber'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> _putRequest(String token, int id, String name, String phone) {
    return http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'emergency_contact_id': id,
        'name': name,
        'phone': phone,
      }),
    );
  }

  Future<http.Response> _deleteRequest(String token, int emergencyContactId) {
    return http.delete(
      Uri.parse('$apiUrl/$emergencyContactId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<String?> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('Refresh');

    if (refreshToken == null || refreshToken.isEmpty) return null;

    final response = await http.post(
      Uri.parse(reissueUrl),
      headers: {
        'Authorization': 'Bearer $refreshToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];

      await prefs.setString('Authorization', newAccessToken);
      await prefs.setString('Refresh', newRefreshToken);
      return newAccessToken;
    }

    return null;
  }
}
