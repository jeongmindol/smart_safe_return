import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackHomeList extends StatefulWidget {
  const BackHomeList({super.key});

  @override
  State<BackHomeList> createState() => _BackHomeListState();
}

class _BackHomeListState extends State<BackHomeList> {
  int? expandedIndex;

  final List<Map<String, String>> records = [
    {
      'title': '안전귀가 001',
      '출발지': '서울역',
      '목적지': '강남역',
      '소요시간': '35분',
      '도착여부': '도착함',
      '생성일': '2024-03-31'
    },
    {
      'title': '안전귀가 002',
      '출발지': '신촌',
      '목적지': '홍대입구',
      '소요시간': '12분',
      '도착여부': '도착함',
      '생성일': '2024-03-30'
    },
    {
      'title': '안전귀가 003',
      '출발지': '건대입구',
      '목적지': '잠실',
      '소요시간': '25분',
      '도착여부': '지연됨',
      '생성일': '2024-03-29'
    },
    {
      'title': '안전귀가 004',
      '출발지': '여의도',
      '목적지': '상암',
      '소요시간': '18분',
      '도착여부': '도착함',
      '생성일': '2024-03-28'
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
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
                    '귀가 기록 보기',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // 리스트 뷰
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final isExpanded = expandedIndex == index;

                    return Column(
                      children: [
                        ListTile(
                          title: Center(
                            // ✅ 제목 중앙 정렬
                            child: Text(
                              record['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              expandedIndex = isExpanded ? null : index;
                            });
                          },
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isExpanded
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center, // ✅ 상세 내용도 중앙 정렬
                                    children: [
                                      Text('출발지: ${record['출발지']}',
                                          style: const TextStyle(fontSize: 18)),
                                      Text('목적지: ${record['목적지']}',
                                          style: const TextStyle(fontSize: 18)),
                                      Text('소요시간: ${record['소요시간']}',
                                          style: const TextStyle(fontSize: 18)),
                                      Text('도착여부: ${record['도착여부']}',
                                          style: const TextStyle(fontSize: 18)),
                                      Text('생성일: ${record['생성일']}',
                                          style: const TextStyle(fontSize: 18)),
                                    ]
                                        .map((widget) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2.0),
                                              child: widget,
                                            ))
                                        .toList(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
