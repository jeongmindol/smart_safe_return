// lib/provider/setting/user/signup_provider.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// 회원가입 API 요청
Future<bool> signupUser({
  required String id,
  required String password,
  required String phone,
  File? imageFile,
}) async {
  final url = Uri.parse(
    'https://smart-safe-return-backend-88013499747.asia-northeast2.run.app/api/member',
  );

  final request = http.MultipartRequest('POST', url);
  request.fields['id'] = id;
  request.fields['password'] = password;
  request.fields['phone'] = phone;

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: p.basename(imageFile.path),
    ));
  }

  try {
    final response = await request.send();
    return response.statusCode == 200;
  } catch (e) {
    print('❌ 네트워크 오류: $e');
    return false;
  }
}

/// 아이디 중복 확인
Future<bool> checkIdDuplicate(String id) async {
  final url = Uri.parse(
    'https://smart-safe-return-backend-88013499747.asia-northeast2.run.app/api/member/check-id?id=$id',
  );

  try {
    final response = await http.get(url);
    return response.statusCode == 200; // 사용 가능
  } catch (e) {
    print('❌ 아이디 중복확인 오류: $e');
    return false;
  }
}

/// 연락처 중복 확인
Future<bool> checkPhoneDuplicate(String phone) async {
  final url = Uri.parse(
    'https://smart-safe-return-backend-88013499747.asia-northeast2.run.app/api/member/check-phone?phone=$phone',
  );

  try {
    final response = await http.get(url);
    return response.statusCode == 200; // 사용 가능
  } catch (e) {
    print('❌ 연락처 중복확인 오류: $e');
    return false;
  }
}
