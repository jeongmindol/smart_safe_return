import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/components/navbar/bottom_bar.dart';
import 'package:smart_safe_return/components/setting/user/signup.dart';
import 'package:smart_safe_return/components/setting/user/id_search.dart';
import 'package:smart_safe_return/components/setting/user/pw_search.dart';
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart'; // ✅ 팝업 import

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final signatureColor = const Color.fromARGB(255, 102, 247, 255);

  @override
  void initState() {
    super.initState();
    checkAutoLogin(ref, context);
  }

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pwController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final id = idController.text.trim();
                    final pw = pwController.text.trim();

                    if (id.isEmpty || pw.isEmpty) {
                      showLoginInputEmptyPopup(context); // ✅ 입력 누락 팝업
                      return;
                    }

                    final success = await login(ref, id, pw);
                    if (success) {
                      // ✅ 팝업 없이 바로 마이페이지로 이동
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Bottom()),
                        );
                      }
                    } else {
                      showLoginFailedPopup(context); // ❌ 실패는 여전히 팝업으로 안내
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signatureColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('로그인'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const IdSearchPage()),
                        );
                      },
                      child: const Text('아이디 찾기'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PwSearchPage()),
                        );
                      },
                      child: const Text('비밀번호 찾기'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignupPage()),
                        );
                      },
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
