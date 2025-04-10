import 'package:flutter/material.dart';
import 'package:smart_safe_return/components/setting/user/user.dart';

/// ✅ 로그인 필요 팝업
void showLoginRequiredPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                '해당 기능을 이용하려면',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Text(
                '로그인이 필요해요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '로그인 페이지로 이동',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ✅ 일반 알림 팝업 (직접 문구 전달)
void showPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('알림'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

/// ✅ 아이디 입력 안 했을 때
void showEmptyIdPopup(BuildContext context) {
  showPopup(context, '아이디를 입력해주세요');
}

/// ✅ 아이디 중복일 때
void showDuplicateIdPopup(BuildContext context) {
  showPopup(context, '이미 사용중인 아이디입니다.');
}

/// ✅ 아이디 사용 가능할 때
void showAvailableIdPopup(BuildContext context) {
  showPopup(context, '사용 가능한 아이디입니다.');
}

/// ✅ 아이디 확인 중 오류 발생 시
void showIdCheckErrorPopup(BuildContext context) {
  showPopup(context, '아이디 확인 중 오류가 발생했습니다');
}
