import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/components/setting/sossms/mysossms_post.dart';
import 'package:smart_safe_return/components/setting/sossms/mysossms_detail.dart';
import 'package:smart_safe_return/provider/setting/sossms/mysossms_detail_provider.dart';

class MySosSms extends ConsumerStatefulWidget {
  const MySosSms({super.key});

  @override
  ConsumerState<MySosSms> createState() => _MySosSmsState();
}

class _MySosSmsState extends ConsumerState<MySosSms> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController messageController = TextEditingController();

  // ✅ 실제 존재하는 회원 번호로 설정
  final int memberNumber = 6;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0;

    // ✅ 탭 전환 시마다 마이메세지 새로고침
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        print("🔁 마이 메세지 탭 새로고침 요청");
        ref.invalidate(sosMessageProvider(memberNumber));
        ref.invalidate(sosMessageIdProvider(memberNumber));
      }
    });

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    print("🧾 화면 진입: memberNumber = $memberNumber");
  }

  @override
  void dispose() {
    _tabController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ⬆️ 상단 타이틀 바
            Container(
              color: signatureColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'SOS 메시지 내용 설정',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ⬆️ 탭바
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const BoxDecoration(
                  color: Color.fromARGB(255, 183, 238, 245),
                ),
                tabs: const [
                  Tab(text: '마이 메세지'),
                  Tab(text: '등록'),
                ],
              ),
            ),

            // ⬇️ 탭 내용
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: const MySosSmsDetail(), // ✅ 자동 새로고침 대상
                  ),
                  SingleChildScrollView(
                    child: MySosSmsPost(
                      messageController: messageController,
                      memberNumber: memberNumber,
                      tabController: _tabController, // ✅ 전달
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
