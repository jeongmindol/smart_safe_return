import 'package:flutter/material.dart';
import 'package:smart_safe_return/provider/setting/user/pw_search_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart'; // ✅ 팝업 import

class PwSearchPage extends StatefulWidget {
  const PwSearchPage({super.key});

  @override
  State<PwSearchPage> createState() => _PwSearchPageState();
}

class _PwSearchPageState extends State<PwSearchPage> {
  final provider = PwSearchProvider();
  static const signatureColor = Color.fromARGB(255, 102, 247, 255);

  @override
  void initState() {
    super.initState();
    provider.onTimerTick = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    provider.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 찾기')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            TextField(
              controller: provider.idController,
              decoration: const InputDecoration(
                hintText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: provider.pwPhoneController,
                    decoration: const InputDecoration(
                      hintText: '휴대전화 (-없이)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await provider.requestPwVerification(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signatureColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("인증 요청"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (provider.isPwCodeInputVisible)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: provider.pwCodeController,
                          decoration: InputDecoration(
                            hintText: '인증 코드 입력',
                            border: const OutlineInputBorder(),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  '${provider.remainingPwSeconds ~/ 60}:${(provider.remainingPwSeconds % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await provider.validatePwCode(context);
                          setState(() {});
                          provider.pwCodeController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("확인"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: (provider.canResendPw &&
                                provider.resendPwCount < 3)
                            ? () async {
                                await provider.requestPwVerification(context);
                                setState(() {});
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (provider.canResendPw &&
                                  provider.resendPwCount < 3)
                              ? Colors.orange
                              : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("재전송"),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (provider.isPwVerificationComplete) ...[
              TextField(
                controller: provider.newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '새 비밀번호 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: provider.confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await provider.resetPassword();

                    if (result.contains('완료')) {
                      showPasswordChangeAndGoToLoginPopup(context);
                      provider.newPasswordController.clear();
                      provider.confirmPasswordController.clear();
                    } else if (result.contains('일치하지 않아요')) {
                      showPasswordMismatchPopup(context);
                    } else if (result.contains('모두 입력')) {
                      showEmptyPasswordPopup(context);
                    } else if (result.contains('인증이 완료되지')) {
                      showTokenInvalidPopup(context);
                    } else if (result.contains('권한')) {
                      showPasswordChangeUnauthorizedPopup(context);
                    } else if (result.contains('요청 중 오류')) {
                      showPasswordChangeErrorPopup(context, result);
                    } else {
                      showPasswordChangeFailedPopup(context, 400);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("비밀번호 변경"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
