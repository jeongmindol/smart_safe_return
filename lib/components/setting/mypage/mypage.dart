import 'package:flutter/material.dart';
import 'package:smart_safe_return/components/setting/mypage/mypageinfo.dart';
import 'package:smart_safe_return/components/setting/mypage/mysection.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 246, 252),
        body: SingleChildScrollView(
          // SingleChildScrollView로 감싸서 스크롤 가능하게 변경
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: signatureColor,
                child: const Center(
                  child: Text(
                    '마이페이지',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const MyPageInfo(),
              const MySection(),
            ],
          ),
        ),
      ),
    );
  }
}
