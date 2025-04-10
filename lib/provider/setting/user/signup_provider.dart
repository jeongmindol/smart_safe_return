import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_safe_return/components/setting/user/user.dart';

/// 연락처 SMS 인증 요청
Future<int?> requestSmsVerification(String phone) async {
  final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/verification/signup/sms');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    if (response.statusCode == 200) {
      return int.tryParse(response.body);
    }
  } catch (e) {
    print('❌ SMS 인증 요청 오류: $e');
  }
  return null;
}

/// 인증번호 확인
Future<bool> verifySmsCode({
  required int verificationId,
  required String code,
}) async {
  final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/verification/signup/sms/validate');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'verification_id': verificationId,
        'code': code,
      }),
    );
    return response.statusCode == 200 && response.body == 'true';
  } catch (e) {
    print('❌ 인증번호 검증 오류: $e');
    return false;
  }
}

/// 아이디 중복 확인
Future<bool?> checkIdDuplicate(String id) async {
  final url = Uri.parse(
    '${dotenv.env['API_BASE_URL']!}/api/member/check-duplicate?id=$id',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body.trim().toLowerCase() == 'true';
    }
  } catch (e) {
    print('❌ 아이디 중복확인 오류: $e');
  }
  return null;
}

/// 회원가입 요청
Future<bool> signupUser({
  required String id,
  required String password,
  required String phone,
  File? imageFile,
}) async {
  final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/member');

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
    print('❌ 회원가입 요청 오류: $e');
    return false;
  }
}

/// 회원가입 처리
Future<void> handleSignup(
  BuildContext context,
  TextEditingController idController,
  TextEditingController passwordController,
  TextEditingController phoneController,
  File? selectedImage,
) async {
  final id = idController.text.trim();
  final pw = passwordController.text.trim();
  final phone = phoneController.text.trim();

  if (id.isEmpty || pw.isEmpty || phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모든 필드를 입력해주세요')),
    );
    return;
  }

  final success = await signupUser(
    id: id,
    password: pw,
    phone: phone,
    imageFile: selectedImage,
  );

  if (!context.mounted) return;

  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserPage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입에 실패했습니다')),
    );
  }
}

/// 체크박스 전체 동의 처리
void toggleAgreeAll({
  required bool? value,
  required void Function(bool) setAgreeAll,
  required void Function(bool) setAgree1,
  required void Function(bool) setAgree2,
  required void Function(bool) setAgree3,
  required void Function(bool) setAgree4,
}) {
  final newValue = value ?? false;
  setAgreeAll(newValue);
  setAgree1(newValue);
  setAgree2(newValue);
  setAgree3(newValue);
  setAgree4(newValue);
}

/// 개별 체크박스 변경 시 전체 동의 체크 상태 업데이트
void updateAgreeAll({
  required bool agree1,
  required bool agree2,
  required bool agree3,
  required bool agree4,
  required void Function(bool) setAgreeAll,
}) {
  setAgreeAll(agree1 && agree2 && agree3 && agree4);
}
