import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/components/setting/user/user.dart'; // 로그인 페이지
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:smart_safe_return/provider/setting/mypage/mypageinfo_provider.dart';
import 'package:smart_safe_return/components/setting/profile/myprofile.dart'; // 내 정보 수정 페이지

class MyPageInfo extends ConsumerWidget {
  const MyPageInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jwt = ref.watch(jwtProvider);
    final id = jwt['id'];

    final memberNumberStr = jwt['memberNumber'];
    final memberNumber = int.tryParse(memberNumberStr ?? '');
    final isLoggedIn = id != null && id.trim().isNotEmpty && memberNumber != null;

    // 로그인 상태일 경우에만 API 호출
    final memberInfoAsync = isLoggedIn
        ? ref.watch(getMemberInfoProvider(memberNumber!))
        : const AsyncValue.data(null);

    return memberInfoAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('오류 발생: $err')),
      data: (memberInfo) {
        // 로그인 상태일 경우 프로필 URL 가져오기
        final profileUrl = memberInfo != null ? memberInfo['profile'] : null;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: CupertinoColors.inactiveGray,
                      backgroundImage: isLoggedIn && profileUrl != null && profileUrl.isNotEmpty
                          ? NetworkImage(profileUrl)
                          : const AssetImage('assets/images/profile.png') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        if (isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyProfile(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserPage(),
                            ),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn ? '$id 님' : '로그인을 해주세요',
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
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        if (isLoggedIn) {
                          handleLogout(context, ref);
                        }
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.star, size: 40, color: Colors.amber),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.warning_amber_rounded,
                          size: 40, color: Colors.redAccent),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
