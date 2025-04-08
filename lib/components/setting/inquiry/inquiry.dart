import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_safe_return/components/setting/inquiry/inquiry_post.dart';

class Inquiry extends StatefulWidget {
  const Inquiry({super.key});

  @override
  State<Inquiry> createState() => _InquiryState();
}

class _InquiryState extends State<Inquiry> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // SingleChildScrollView로 감싸서 스크롤 가능하게 변경
          child: Column(
            children: [
              // 🔵 상단 바
              Container(
                color: signatureColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      '문의 목록',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // 🔵 탭바
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: const BoxDecoration(
                    color: Color.fromARGB(255, 183, 238, 245),
                  ),
                  tabs: const [
                    Tab(text: '문의 처리중'),
                    Tab(text: '문의 완료'),
                  ],
                ),
              ),

              // 🔵 탭 뷰
              SizedBox(
                height: 400, // 탭뷰에 고정된 크기를 설정
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    Center(child: Text('문의 처리중 목록')),
                    Center(child: Text('문의 완료 목록')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔵 플로팅 버튼 (문의 등록으로 이동)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InquiryPost()),
          );
        },
        backgroundColor: signatureColor,
        child: const Icon(Icons.headset_mic),
      ),
    );
  }
}
