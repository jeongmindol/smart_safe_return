import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

class IdSearchProvider {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  int? verificationId;
  bool isCodeInputVisible = false;
  bool isVerificationComplete = false;
  int resendCount = 0;
  bool canResend = true;
  int remainingSeconds = 180;
  String? foundId;

  Timer? _timer;
  VoidCallback? onTimerTick;

  // 🔹 아이디 인증 요청
  Future<void> requestIdVerification(BuildContext context) async {
    if (!canResend || resendCount >= 3) return;

    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      showEmptyPhonePopup(context);
      return;
    }

    final url =
        Uri.parse('${dotenv.env['API_BASE_URL']!}/api/verification/id/sms');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '{"phone":"$phone"}',
      );

      print('응답 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        verificationId = int.tryParse(response.body);
        if (verificationId != null) {
          isCodeInputVisible = true;
          isVerificationComplete = false;
          foundId = null;
          _startTimer();
          resendCount++;
          _startResendCooldown();
        }
      } else if (response.statusCode == 400 || response.statusCode == 403 || response.statusCode == 404) {
        showUnregisteredPhonePopup(context); // ✅ 등록되지 않은 연락처 팝업
      } else {
        print('❌ 알 수 없는 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ 아이디 인증 요청 실패: $e");
    }
  }

  // 🔹 아이디 찾기
  Future<String?> findId() async {
    final phone = phoneController.text.trim();
    final code = codeController.text.trim();
    if (verificationId == null) return null;

    final url = Uri.parse(
        '${dotenv.env['API_BASE_URL']!}/api/verification/id/sms/validate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''
        {
          "phone": "$phone",
          "verification_id": $verificationId,
          "code": "$code"
        }
        ''',
      );

      if (response.statusCode == 200) {
        final id = response.body;
        isVerificationComplete = true;
        foundId = id;
        return id;
      }

      isVerificationComplete = false;
      return null;
    } catch (e) {
      print("❌ 아이디 검증 실패: $e");
      return null;
    }
  }

  // 🔹 타이머 시작
  void _startTimer() {
    remainingSeconds = 180;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds--;
      if (remainingSeconds <= 0) {
        timer.cancel();
        isCodeInputVisible = false;
        isVerificationComplete = false;
      }
      onTimerTick?.call();
    });
  }

  // 🔹 재전송 제한 쿨다운
  void _startResendCooldown() {
    canResend = false;
    onTimerTick?.call();

    Future.delayed(const Duration(seconds: 5), () {
      canResend = true;
      onTimerTick?.call();
    });
  }

  // 🔹 컨트롤러 정리
  void disposeControllers() {
    phoneController.dispose();
    codeController.dispose();
    _timer?.cancel();
  }
}
