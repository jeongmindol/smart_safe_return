import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ 추가
import 'package:smart_safe_return/components/setting/safeguard/mysafeguard_post.dart';
import 'package:smart_safe_return/components/setting/safeguard/mysafeguard_list.dart';

class MySafeguard extends StatefulWidget {
  const MySafeguard({super.key});

  @override
  State<MySafeguard> createState() => _MySafeguardState();
}

class _MySafeguardState extends State<MySafeguard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<MySafeguardListState> listKey = GlobalKey<MySafeguardListState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    checkAccessToken(); // ✅ 콘솔에 토큰 출력

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }

  /// ✅ Access Token 콘솔에 출력하는 함수
  void checkAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('Authorization');
    print("🪪 AccessToken = $accessToken");
  }

  void addGuardian(String name, String phone) {
    listKey.currentState?.refreshGuardians();
    _tabController.animateTo(1); // 목록 탭으로 이동
  }

  @override
  Widget build(BuildContext context) {
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
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
                          '긴급 연락처 설정',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: const BoxDecoration(
                        color: Color.fromARGB(255, 159, 208, 214),
                      ),
                      tabs: const [
                        Tab(text: '등록'),
                        Tab(text: '목록'),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        MySafeguardPost(onAddGuardian: addGuardian),
                        MySafeguardList(key: listKey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
