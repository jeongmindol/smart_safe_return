// inquiry.dart 전체 수정 코드 (popup_box.dart 변경사항 반영)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/components/setting/inquiry/inquiry_post.dart';
import 'package:smart_safe_return/provider/setting/inquiry/inquiry_provider.dart';
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

final currentMemberNumberProvider = Provider<int>((ref) {
  final Map<String, String?> jwt = ref.watch(jwtProvider);
  final memberNumberStr = jwt['memberNumber'];
  if (memberNumberStr == null || memberNumberStr.isEmpty) throw Exception('로그인 정보가 없습니다.');
  final memberNumber = int.tryParse(memberNumberStr);
  if (memberNumber == null) throw Exception('memberNumber 파싱 실패');
  return memberNumber;
});

class Inquiry extends ConsumerStatefulWidget {
  const Inquiry({super.key});

  @override
  ConsumerState<Inquiry> createState() => _InquiryState();
}

class _InquiryState extends ConsumerState<Inquiry> with TickerProviderStateMixin {
  late TabController _tabController;
  int? expandedId;
  Map<int, bool> isEditingMap = {};
  Map<int, TextEditingController> titleControllers = {};
  Map<int, TextEditingController> contentControllers = {};
  Map<int, String> selectedCategoryMap = {};
  int? memberNumber;

  final List<String> categories = [
    '기타', '회원 정보', '연락처', 'SMS', '귀가 로그', '지도', '버그 신고', '보안 문의'
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    memberNumber = ref.read(currentMemberNumberProvider);
    ref.refresh(inquiryListProvider(memberNumber!));
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in titleControllers.values) {
      controller.dispose();
    }
    for (var controller in contentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (memberNumber == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final inquiryAsync = ref.watch(inquiryListProvider(memberNumber!));
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                    '문의 목록',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: const BoxDecoration(color: Color.fromARGB(255, 183, 238, 245)),
              tabs: const [
                Tab(text: '문의 처리중'),
                Tab(text: '문의 완료'),
              ],
            ),
            Expanded(
              child: inquiryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('❌ 문의 불러오기 실패: $err')),
                data: (inquiries) {
                  final inProgress = inquiries.where((q) => q.status == 'IN_PROGRESS').toList();
                  final completed = inquiries.where((q) => q.status == 'COMPLETED').toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInquiryList(inProgress, true),
                      _buildInquiryList(completed, false),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InquiryPost()),
          ).then((_) => ref.refresh(inquiryListProvider(memberNumber!)));
        },
        backgroundColor: signatureColor,
        child: const Icon(Icons.headset_mic),
      ),
    );
  }

  Widget _buildInquiryList(List<InquiryQuestion> inquiries, bool isEditable) {
    if (inquiries.isEmpty) {
      return const Center(child: Text("문의 내역이 없습니다."));
    }

    return ListView.builder(
      itemCount: inquiries.length,
      itemBuilder: (context, index) {
        final inquiry = inquiries[index];
        final isExpanded = expandedId == inquiry.questionId;
        final isEditing = isEditingMap[inquiry.questionId] ?? false;

        titleControllers[inquiry.questionId] ??= TextEditingController(text: inquiry.title);
        contentControllers[inquiry.questionId] ??= TextEditingController(text: inquiry.content);
        selectedCategoryMap[inquiry.questionId] ??= inquiry.categoryName;

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  expandedId = isExpanded ? null : inquiry.questionId;
                });
              },
              child: ListTile(
                tileColor: Colors.white,
                title: Text(
                  inquiry.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  inquiry.categoryName,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("문의 내용", inquiry.content),
                    _infoRow("문의 최종 등록일", inquiry.formattedDate),
                    const SizedBox(height: 8),
                    if (isEditable)
                      isEditing
                          ? Column(
                              children: [
                                TextField(
                                  controller: titleControllers[inquiry.questionId],
                                  decoration: const InputDecoration(labelText: '제목'),
                                ),
                                DropdownButton<String>(
                                  value: selectedCategoryMap[inquiry.questionId],
                                  isExpanded: true,
                                  items: categories
                                      .map((category) => DropdownMenuItem(
                                            value: category,
                                            child: Text(category),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedCategoryMap[inquiry.questionId] = value;
                                      });
                                    }
                                  },
                                ),
                                TextField(
                                  controller: contentControllers[inquiry.questionId],
                                  maxLines: 5,
                                  decoration: const InputDecoration(labelText: '문의 내용'),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditingMap[inquiry.questionId] = false;
                                        });
                                      },
                                      child: const Text('취소'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final updated = await ref.read(updateInquiryProvider({
                                          'question_id': inquiry.questionId,
                                          'title': titleControllers[inquiry.questionId]!.text,
                                          'category': selectedCategoryMap[inquiry.questionId],
                                          'content': contentControllers[inquiry.questionId]!.text,
                                        }).future);
                                        if (updated) {
                                          setState(() {
                                            isEditingMap[inquiry.questionId] = false;
                                            expandedId = null;
                                          });
                                          showPopup(context, '문의가 수정되었습니다.');
                                          ref.refresh(inquiryListProvider(memberNumber!));
                                        }
                                      },
                                      child: const Text('확인'),
                                    ),
                                  ],
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditingMap[inquiry.questionId] = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("수정"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showDeleteConfirmPopup(
                                      context,
                                      onConfirm: () async {
                                        final deleted = await ref.read(deleteInquiryProvider(inquiry.questionId).future);
                                        if (deleted) {
                                          setState(() {
                                            expandedId = null;
                                          });
                                          showPopup(context, '삭제가 완료되었습니다.');
                                          ref.refresh(inquiryListProvider(memberNumber!));
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("삭제"),
                                ),
                              ],
                            )
                  ],
                ),
              ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}