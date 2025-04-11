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

/// ✅ 공통 알림 팝업
void showPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      actionsPadding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      actionsAlignment: MainAxisAlignment.end,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 2,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

/// ✅ 아이디 관련 팝업
void showEmptyIdPopup(BuildContext context) {
  showPopup(context, '아이디를 입력해주세요');
}

void showDuplicateIdPopup(BuildContext context) {
  showPopup(context, '이미 사용중인 아이디입니다.');
}

void showAvailableIdPopup(BuildContext context) {
  showPopup(context, '사용 가능한 아이디입니다.');
}

void showIdCheckErrorPopup(BuildContext context) {
  showPopup(context, '아이디 확인 중 오류가 발생했습니다');
}

/// ✅ 연락처 관련 팝업
void showEmptyPhonePopup(BuildContext context) {
  showPopup(context, '연락처를 입력해주세요');
}

void showUnregisteredPhonePopup(BuildContext context) {
  showPopup(context, '아이디 또는 연락처가 일치하지 않습니다\n다시 입력해주세요');
}

/// ✅ 인증 코드 관련 팝업
void showInvalidCodePopup(BuildContext context) {
  showPopup(context, '인증 코드가 올바르지 않아요.');
}

/// ✅ 로그인 관련 팝업
void showLoginInputEmptyPopup(BuildContext context) {
  showPopup(context, '아이디와 비밀번호를 입력해주세요');
}

void showLoginFailedPopup(BuildContext context) {
  showPopup(context, '아이디 또는 비밀번호가 일치하지 않습니다 \n다시 입력해주세요');
}

/// ✅ 비밀번호 찾기 관련 팝업
void showMissingIdOrPhonePopup(BuildContext context) {
  showPopup(context, '아이디 또는 휴대전화를\n다시 입력해주세요');
}

void showEmptyPasswordPopup(BuildContext context) {
  showPopup(context, '비밀번호를 모두 입력해주세요');
}

void showPasswordMismatchPopup(BuildContext context) {
  showPopup(context, '비밀번호가 일치하지 않아요');
}

void showTokenInvalidPopup(BuildContext context) {
  showPopup(context, '인증이 완료되지 않았어요');
}

void showPasswordChangeSuccessPopup(BuildContext context) {
  showPopup(context, '비밀번호 변경이 완료되었습니다');
}

void showPasswordChangeFailedPopup(BuildContext context, int statusCode) {
  showPopup(context, '비밀번호 변경에 실패했어요 ($statusCode)');
}

void showPasswordChangeUnauthorizedPopup(BuildContext context) {
  showPopup(context, '비밀번호 변경 권한이 없어요\n(토큰 만료 또는 유효하지 않음)');
}

void showPasswordChangeErrorPopup(BuildContext context, Object error) {
  showPopup(context, '요청 중 오류가 발생했어요:\n$error');
}

/// ✅ 비밀번호 변경 성공 후 로그인 이동 팝업
void showPasswordChangeAndGoToLoginPopup(BuildContext context) {
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
              const Text(
                '비밀번호 변경이 완료되었습니다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 팝업 닫기
                  Navigator.pushReplacement(
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
