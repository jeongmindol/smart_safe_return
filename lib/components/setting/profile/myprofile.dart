import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  // 💙 signatureColor 여기서 정의!
  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 246, 252),
      body: SafeArea(
        child: SingleChildScrollView(
          // SingleChildScrollView로 감싸서 스크롤 가능하게 변경
          child: Column(
            children: [
              // 🔹 상단 바
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                color: signatureColor,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      '내 정보 수정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // 🔹 본문 영역
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildProfileItem('아이디', '라이언', () {
                      print("ID 수정");
                    }),
                    const Divider(),
                    buildProfileItem('비밀번호', '********', () {
                      print("비밀번호 수정");
                    }),
                    const Divider(),
                    buildProfileItem(
                        '연락처', '010 - 0810 - 2135', null), // 👈 수정 버튼 없음!
                    const SizedBox(height: 40),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // ✅ 탈퇴 확인 알림창 (중앙)
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  '회원 탈퇴',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: const Text('정말 탈퇴하시겠어요?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('아니요'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      print("정말 탈퇴합니다!");
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('네, 탈퇴할게요'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          '회원 탈퇴',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ 수정 버튼은 onEdit이 null 아닐 때만 보이도록!
  Widget buildProfileItem(String title, String value, VoidCallback? onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text('$title: $value', style: const TextStyle(fontSize: 16)),
          ),
          if (onEdit != null)
            ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: signatureColor,
                foregroundColor: Colors.black,
              ),
              child: const Text('수정'),
            ),
        ],
      ),
    );
  }
}
