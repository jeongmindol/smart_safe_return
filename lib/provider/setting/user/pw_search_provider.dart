import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

class PwSearchProvider {
  final idController = TextEditingController();
  final pwPhoneController = TextEditingController();
  final pwCodeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int? verificationPwId;
  String? resetToken;
  bool isPwCodeInputVisible = false;
  bool isPwVerificationComplete = false;
  int resendPwCount = 0;
  bool canResendPw = true;
  int remainingPwSeconds = 180;

  Timer? _pwTimer;
  VoidCallback? onTimerTick;

  // ✅ 인증 요청
  Future<void> requestPwVerification(BuildContext context) async {
    final phone = pwPhoneController.text.trim();
    final memberId = idController.text.trim();

    if (phone.isEmpty || memberId.isEmpty) {
      showMissingIdOrPhonePopup(context);
      return;
    }

    final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/verification/password/sms');
    print('📡 인증 요청 → {"phone": "$phone", "member_id": "$memberId"}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '{"phone": "$phone", "member_id": "$memberId"}',
      );

      print('📨 인증 응답 → ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        verificationPwId = int.tryParse(response.body);
        if (verificationPwId != null) {
          isPwCodeInputVisible = true;
          isPwVerificationComplete = false;
          _startPwTimer();
          resendPwCount++;
          _startPwResendCooldown();
        }
      } else {
        showUnregisteredPhonePopup(context);
      }
    } catch (e) {
      print('❌ 인증 요청 실패: $e');
    }
  }

  // ✅ 인증 코드 확인 + 토큰 저장
  Future<void> validatePwCode(BuildContext context) async {
    final phone = pwPhoneController.text.trim();
    final code = pwCodeController.text.trim();

    if (code.isEmpty) {
      showInvalidCodePopup(context);
      return;
    }

    if (verificationPwId == null) return;

    final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/verification/password/sms/validate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''
        {
          "phone": "$phone",
          "verification_id": $verificationPwId,
          "code": "$code"
        }
        '''.trim(),
      );

      print('✅ 코드 검증 응답 → ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        resetToken = response.body.replaceAll('"', '');
        isPwVerificationComplete = true;
      } else {
        isPwVerificationComplete = false;
        showInvalidCodePopup(context);
      }
    } catch (e) {
      print('❌ 인증 코드 검증 실패: $e');
      showInvalidCodePopup(context);
    }
  }

  // ✅ 비밀번호 재설정 - 토큰 포함
  Future<String> resetPassword() async {
    final password = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final id = idController.text.trim();

    print('🔐 비밀번호 변경 시도');
    print('🧾 id: $id');
    print('🔑 password: $password');
    print('✅ 인증 완료 여부: $isPwVerificationComplete');
    print('🪪 토큰: $resetToken');

    if (password.isEmpty || confirmPassword.isEmpty) {
      return '비밀번호를 모두 입력해주세요';
    }

    if (password != confirmPassword) {
      return '비밀번호가 일치하지 않아요';
    }

    if (!isPwVerificationComplete || resetToken == null) {
      return '인증이 완료되지 않았어요';
    }

    final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/verification/password/reset');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''
        {
          "member_id": "$id",
          "password": "$password",
          "token": "$resetToken"
        }
        '''.trim(),
      );

      print('📨 비밀번호 변경 응답 → ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        return '비밀번호 변경이 완료되었습니다';
      } else if (response.statusCode == 403) {
        return '비밀번호 변경 권한이 없어요 (403)';
      } else {
        return '비밀번호 변경에 실패했어요 (${response.statusCode})';
      }
    } catch (e) {
      return '요청 중 오류가 발생했어요: $e';
    }
  }

  void _startPwTimer() {
    remainingPwSeconds = 180;

    _pwTimer?.cancel();
    _pwTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingPwSeconds--;
      if (remainingPwSeconds <= 0) {
        timer.cancel();
        isPwCodeInputVisible = false;
        isPwVerificationComplete = false;
      }
      onTimerTick?.call();
    });
  }

  void _startPwResendCooldown() {
    canResendPw = false;
    onTimerTick?.call();

    Future.delayed(const Duration(seconds: 5), () {
      canResendPw = true;
      onTimerTick?.call();
    });
  }

  void disposeControllers() {
    idController.dispose();
    pwPhoneController.dispose();
    pwCodeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _pwTimer?.cancel();
  }
}
