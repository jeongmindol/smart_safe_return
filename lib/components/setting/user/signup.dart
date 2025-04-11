import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_safe_return/components/setting/user/user.dart';
import 'package:smart_safe_return/provider/setting/user/signup_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  int? verificationId;
  bool isVerifying = false;
  int remainingSeconds = 180;
  Timer? timer;

  bool isIdAvailable = false;
  bool isPhoneVerified = false;

  bool agreeAll = false;
  bool agree1 = false;
  bool agree2 = false;
  bool agree3 = false;
  bool agree4 = false;

  bool get isSignupEnabled =>
      isIdAvailable &&
      isPhoneVerified &&
      passwordController.text.isNotEmpty &&
      agree1 && agree2 && agree3;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏰ 인증 시간이 만료되었습니다')),
        );
      }
    });
  }

  void handleVerifyRequest() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연락처를 입력해주세요')),
      );
      return;
    }

    final id = await requestSmsVerification(phone);
    if (id != null) {
      setState(() {
        verificationId = id;
        isVerifying = true;
        remainingSeconds = 180;
      });
      startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 인증번호가 전송되었습니다')),
      );
    }
  }

  void handleCodeSubmit() async {
    if (verificationId == null || codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호를 입력해주세요')),
      );
      return;
    }

    final success = await verifySmsCode(
      verificationId: verificationId!,
      code: codeController.text.trim(),
    );

    if (success) {
      showPopup(context, '인증이 완료되었습니다!');
      setState(() {
        isPhoneVerified = true;
        isVerifying = false;
        verificationId = null;
        timer?.cancel();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 인증번호가 틀렸습니다')),
      );
    }
  }

  void handleIdCheckWrapper() async {
    final id = idController.text.trim();
    if (id.isEmpty) return;
    final isDup = await checkIdDuplicate(id);
    setState(() {
      isIdAvailable = isDup == false;
    });
    if (isDup == null) {
      showIdCheckErrorPopup(context);
    } else if (isDup) {
      showDuplicateIdPopup(context);
    } else {
      showAvailableIdPopup(context);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: handleIdCheckWrapper,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: signatureColor,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('중복확인'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: '연락처(-없이 입력)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: handleVerifyRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: signatureColor,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('승인요청'),
                  ),
                ],
              ),
              if (isVerifying) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: codeController,
                        decoration: InputDecoration(
                          labelText: '인증번호 입력',
                          border: const OutlineInputBorder(),
                          suffixText:
                              '${(remainingSeconds ~/ 60).toString().padLeft(1, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: handleCodeSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: signatureColor,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('인증확인'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: handleVerifyRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('재전송'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
               const SizedBox(height: 20),
              const Text('프로필 이미지'),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _selectedImage == null
                        ? const Text('이미지를 선택하세요')
                        : Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildCheckbox('모두 동의합니다.', agreeAll, (value) {
                setState(() {
                  toggleAgreeAll(
                    value: value,
                    setAgreeAll: (v) => agreeAll = v,
                    setAgree1: (v) => agree1 = v,
                    setAgree2: (v) => agree2 = v,
                    setAgree3: (v) => agree3 = v,
                    setAgree4: (v) => agree4 = v,
                  );
                });
              }),
              buildCheckbox('[필수] 안전귀가 서비스 이용약관', agree1, (value) {
                setState(() {
                  agree1 = value ?? false;
                  updateAgreeAll(
                    agree1: agree1,
                    agree2: agree2,
                    agree3: agree3,
                    agree4: agree4,
                    setAgreeAll: (v) => agreeAll = v,
                  );
                });
              }),
              buildCheckbox('[필수] 개인정보 수집 및 이용', agree2, (value) {
                setState(() {
                  agree2 = value ?? false;
                  updateAgreeAll(
                    agree1: agree1,
                    agree2: agree2,
                    agree3: agree3,
                    agree4: agree4,
                    setAgreeAll: (v) => agreeAll = v,
                  );
                });
              }),
              buildCheckbox('[필수] 위치 기반 서비스 이용약관', agree3, (value) {
                setState(() {
                  agree3 = value ?? false;
                  updateAgreeAll(
                    agree1: agree1,
                    agree2: agree2,
                    agree3: agree3,
                    agree4: agree4,
                    setAgreeAll: (v) => agreeAll = v,
                  );
                });
              }),
              buildCheckbox('[선택] 광고성 정보 수신 동의', agree4, (value) {
                setState(() {
                  agree4 = value ?? false;
                  updateAgreeAll(
                    agree1: agree1,
                    agree2: agree2,
                    agree3: agree3,
                    agree4: agree4,
                    setAgreeAll: (v) => agreeAll = v,
                  );
                });
              }),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isSignupEnabled
                      ? () => handleSignup(
                            context,
                            idController,
                            passwordController,
                            phoneController,
                            _selectedImage,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signatureColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('등록', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 체크박스 스타일 함수 (왼쪽 서클 + Signature 색상)
  Widget buildCheckbox(String text, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(text),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color.fromARGB(255, 102, 247, 255),
      checkColor: Colors.white,
    );
  }
}
