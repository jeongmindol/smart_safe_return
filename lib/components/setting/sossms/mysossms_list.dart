import 'package:flutter/material.dart';

class MySosSmsList extends StatefulWidget {
  final List<String> savedTitles;

  const MySosSmsList({super.key, required this.savedTitles});

  @override
  State<MySosSmsList> createState() => _MySosSmsListState();
}

class _MySosSmsListState extends State<MySosSmsList> {
  int? expandedIndex;

  // 💙 signatureColor 정의
  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);

  final Map<String, String> details = {
    '안전 귀가길 SOS': '상세내용1',
    '안전 출근길 SOS': '상세내용2',
    '안전 퇴근길 SOS': '상세내용3',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 여기에서 SingleChildScrollView를 추가하여 부모를 스크롤 가능하게 함
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true, // 이 속성은 ListView의 크기를 부모로 제한하여 다른 스크롤 문제를 피합니다.
              physics:
                  NeverScrollableScrollPhysics(), // 내부 ListView가 스크롤을 관리하도록 함
              itemCount: widget.savedTitles.length,
              itemBuilder: (context, index) {
                final title = widget.savedTitles[index];
                final isExpanded = expandedIndex == index;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          print('선택됨: $title');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: signatureColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // ✅ radius 적용!
                          ),
                        ),
                        child: const Text('선택'),
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      details[title] ?? '상세 내용 없음',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      print('수정 클릭: $title');
                                    },
                                    child: const Text(
                                      '수정',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
