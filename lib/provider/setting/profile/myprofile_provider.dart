import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:path/path.dart' as p;

// ✅ 사용자 정보 모델
class MemberData {
  final String id;
  final String phone;
  final String? profile;

  MemberData({required this.id, required this.phone, this.profile});

  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      profile: json['profile'],
    );
  }
}

// ✅ 사용자 정보 조회 provider
final myProfileProvider = FutureProvider<MemberData>((ref) async {
  final jwt = ref.watch(jwtProvider);
  final memberNumber = jwt['memberNumber'];
  final token = jwt['Authorization'];

  if (memberNumber == null || token == null) {
    throw Exception('로그인 정보가 없습니다');
  }

  final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/member/$memberNumber');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);
    return MemberData.fromJson(jsonBody);
  } else {
    throw Exception('회원 정보를 불러오는 데 실패했습니다: ${response.statusCode}');
  }
});

// ✅ 회원 정보 수정
Future<bool> updateMyProfile({
  required WidgetRef ref,
  String? phone,
  String? password,
  File? imageFile,
}) async {
  final jwt = ref.read(jwtProvider);
  final memberNumber = jwt['memberNumber'];
  final token = jwt['Authorization'];

  if (memberNumber == null || token == null) {
    throw Exception('로그인 정보가 없습니다');
  }

  final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/member/$memberNumber');

  final request = http.MultipartRequest('PUT', url)
    ..headers['Authorization'] = 'Bearer $token'
    ..fields['memberNumber'] = memberNumber.toString();

  if (phone != null) request.fields['phone'] = phone;
  if (password != null) request.fields['password'] = password;

  if (imageFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path, filename: p.basename(imageFile.path)),
    );
  }

  final response = await request.send();
  return response.statusCode == 200;
}

// ✅ 회원 탈퇴 요청
Future<bool> deleteMyAccount(WidgetRef ref) async {
  final jwt = ref.read(jwtProvider);
  final memberNumber = jwt['memberNumber'];
  final token = jwt['Authorization'];

  if (memberNumber == null || token == null) {
    throw Exception('로그인 정보가 없습니다');
  }

  final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/member/$memberNumber');

  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return response.statusCode == 200;
}

// ✅ 비밀번호 확인 요청
Future<bool> checkPasswordMatch({
  required WidgetRef ref,
  required String inputId,
  required String inputPassword,
}) async {
  final jwt = ref.read(jwtProvider);
  final token = jwt['Authorization'];
  final memberNumber = jwt['memberNumber'];

  if (memberNumber == null || token == null) {
    throw Exception('로그인 정보가 없습니다');
  }

  final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/member/$memberNumber/password-check');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'id' : inputId,
      'password': inputPassword}),
  );

  print("비밀번호 체크 바디 = " + response.body);


  final check = response.body.trim().toLowerCase() == 'true';
  return check;
}
