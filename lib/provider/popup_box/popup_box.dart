import 'package:flutter/material.dart';
import 'package:smart_safe_return/components/setting/user/user.dart';
import 'package:smart_safe_return/components/setting/inquiry/inquiry.dart';
import 'dart:async';

/// ✅ 기본 팝업 함수
void showPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '알림',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('확인'),
          )
        ],
      );
    },
  );
}

/// ✅ 문의 수정 완료 팝업
void showInquiryUpdateSuccessPopup(BuildContext context) => showPopup(context, '문의가 수정되었습니다.');

/// ✅ 삭제 완료 팝업 (닫은 후 inquiry 페이지로 이동)
void showDeleteSuccessPopup(BuildContext context) {
  // ✅ 기존 팝업이 여러 겹으로 남아 있지 않도록 모두 닫기
  while (Navigator.canPop(context)) {
    Navigator.of(context).pop();
  }

  // ✅ 삭제 완료 알림창 하나만 띄우기
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (popupContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '삭제 완료',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '삭제가 완료되었습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(popupContext).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Inquiry()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('확인'),
          )
        ],
      );
    },
  );
}

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

/// ✅ 삭제 확인 팝업 (확인 시 알림창 닫고 완료 팝업)
void showDeleteConfirmPopup(
  BuildContext context, {
  required FutureOr<bool?> Function()? onConfirm,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '삭제 확인',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '정말로 삭제하시겠습니까?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              if (onCancel != null) {
                onCancel();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await onConfirm?.call();
              if ((result ?? true) && context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                showDeleteSuccessPopup(context); // ✅ 삭제 완료 알림 표시 및 이동
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}


// ──────────────── 🔐 기타 팝업 묶음 ────────────────
void showLoginInputEmptyPopup(BuildContext context) => showPopup(context, '아이디와 비밀번호를 입력해주세요');
void showLoginFailedPopup(BuildContext context) => showPopup(context, '아이디 또는 비밀번호가 일치하지 않습니다 \n다시 입력해주세요');
void showSignupFailedPopup(BuildContext context) => showPopup(context, '회원가입에 실패했습니다');
void showEmptySignupFieldPopup(BuildContext context) => showPopup(context, '모든 필드를 입력해주세요');
void showMissingIdOrPhonePopup(BuildContext context) => showPopup(context, '아이디 또는 휴대전화를\n다시 입력해주세요');
void showEmptyPasswordPopup(BuildContext context) => showPopup(context, '비밀번호를 모두 입력해주세요');
void showPasswordMismatchPopup(BuildContext context) => showPopup(context, '비밀번호가 일치하지 않아요');
void showTokenInvalidPopup(BuildContext context) => showPopup(context, '인증이 완료되지 않았어요');
void showPasswordChangeSuccessPopup(BuildContext context) => showPopup(context, '비밀번호 변경이 완료되었습니다');
void showPasswordChangeFailedPopup(BuildContext context, int statusCode) => showPopup(context, '비밀번호 변경에 실패했어요 ($statusCode)');
void showPasswordChangeUnauthorizedPopup(BuildContext context) => showPopup(context, '비밀번호 변경 권한이 없어요\n(토큰 만료 또는 유효하지 않음)');
void showPasswordChangeErrorPopup(BuildContext context, Object error) => showPopup(context, '요청 중 오류가 발생했어요:\n$error');
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
                  Navigator.pop(context);
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
void showInvalidCodePopup(BuildContext context) => showPopup(context, ' 인증번호가 틀렸습니다');
void showVerificationTimeoutPopup(BuildContext context) => showPopup(context, ' 인증 시간이 만료되었습니다');
void showVerificationSentPopup(BuildContext context) => showPopup(context, ' 인증번호가 전송되었습니다');
void showEnterVerificationCodePopup(BuildContext context) => showPopup(context, '인증번호를 입력해주세요');
void showEmptyIdPopup(BuildContext context) => showPopup(context, '아이디를 입력해주세요');
void showDuplicateIdPopup(BuildContext context) => showPopup(context, '이미 사용중인 아이디입니다.');
void showAvailableIdPopup(BuildContext context) => showPopup(context, '사용 가능한 아이디입니다.');
void showIdCheckErrorPopup(BuildContext context) => showPopup(context, '아이디 확인 중 오류가 발생했습니다');
void showEmptyPhonePopup(BuildContext context) => showPopup(context, '연락처를 입력해주세요');
void showUnregisteredPhonePopup(BuildContext context) => showPopup(context, '아이디 또는 연락처가 일치하지 않습니다\n다시 입력해주세요');
void showPhoneAlreadyRegisteredPopup(BuildContext context) => showPopup(context, '이미 등록된 연락처입니다');
void showGuardianRegisterSuccessPopup(BuildContext context) => showPopup(context, ' 안전지킴이 등록 완료');
void showGuardianRegisterFailPopup(BuildContext context) => showPopup(context, ' 이미 등록된 연락처입니다. 다시 확인해주세요');
void showEmptyGuardianFieldPopup(BuildContext context) => showPopup(context, '이름, 연락처를 다시 입력해주세요');
void showGuardianUpdateSuccessPopup(BuildContext context) => showPopup(context, '수정이 완료되었습니다.');
void showAccountDeletedPopup(BuildContext context) {
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
                '회원 탈퇴가 완료되었습니다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const UserPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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
void showWithdrawConfirmPopup(BuildContext context, VoidCallback onConfirm, VoidCallback onCancel) {
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
                '정말 탈퇴하시겠습니까?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('취소', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('확인', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}