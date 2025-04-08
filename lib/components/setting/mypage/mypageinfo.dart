import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/components/setting/user/user.dart';
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:smart_safe_return/provider/setting/mypage/mypageinfo_provider.dart';

class MyPageInfo extends ConsumerWidget {
  const MyPageInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jwt = ref.watch(jwtProvider);
    final id = jwt['id'];
    final isIdValid = id != null && id.trim().isNotEmpty;

    print('🧪 jwtProvider 상태: $jwt');
    print('🧪 id 값: $id');

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                  backgroundColor: CupertinoColors.inactiveGray,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIdValid ? '$id 님' : '불러오는 중...',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '안전 귀가 이용자',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    handleLogout(context, ref);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, size: 40, color: Colors.grey),
                  onPressed: () {
                    print("집 아이콘 눌림!");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star, size: 40, color: Colors.amber),
                  onPressed: () {
                    print("별 아이콘 눌림!");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.warning_amber_rounded,
                      size: 40, color: Colors.redAccent),
                  onPressed: () {
                    print("사이렌 아이콘 눌림!");
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
