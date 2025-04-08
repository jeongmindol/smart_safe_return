import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_safe_return/components/setting/sossms/mysossms_post.dart';
import 'package:smart_safe_return/components/setting/sossms/mysossms_list.dart';

class MySosSms extends StatefulWidget {
  const MySosSms({super.key});

  @override
  State<MySosSms> createState() => _MySosSmsState();
}

class _MySosSmsState extends State<MySosSms> with TickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final List<String> savedTitles = [
    '안전 귀가길 SOS',
    '안전 출근길 SOS',
    '안전 퇴근길 SOS',
  ];

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

  void saveMessage() {
    print('제목: ${titleController.text}');
    print('메시지: ${messageController.text}');
    // TODO: 저장 로직 연동
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
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
            // 상단 앱바
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

            // 탭바
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
                  Tab(text: '등록'),
                  Tab(text: '목록'),
                ],
              ),
            ),

            // 탭 내용
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    // 등록 화면에 스크롤 기능 추가
                    child: MySosSmsPost(
                      titleController: titleController,
                      messageController: messageController,
                      onSave: saveMessage,
                    ),
                  ),
                  SingleChildScrollView(
                    // 목록 화면에 스크롤 기능 추가
                    child: MySosSmsList(savedTitles: savedTitles),
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
