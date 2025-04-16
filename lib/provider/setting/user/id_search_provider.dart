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

  Future<void> requestIdVerification(BuildContext context) async {
    if (!canResend || resendCount >= 3) return;

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      showEmptyPhonePopup(context);
      return;
    }

    final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/verification/id/sms');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '{"phone":"$phone"}',
      );

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
      } else if ([400, 403, 404].contains(response.statusCode)) {
        showUnregisteredPhonePopup(context);
      }
    } catch (_) {
      // 실패 시 무시
    }
  }

  Future<String?> findId() async {
    final phone = phoneController.text.trim();
    final code = codeController.text.trim();
    if (verificationId == null) return null;

    final url = Uri.parse('${dotenv.env['API_BASE_URL']!}/api/verification/id/sms/validate');

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
    } catch (_) {
      return null;
    }
  }

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

  void _startResendCooldown() {
    canResend = false;
    onTimerTick?.call();

    Future.delayed(const Duration(seconds: 5), () {
      canResend = true;
      onTimerTick?.call();
    });
  }

  void disposeControllers() {
    phoneController.dispose();
    codeController.dispose();
    _timer?.cancel();
  }
}
