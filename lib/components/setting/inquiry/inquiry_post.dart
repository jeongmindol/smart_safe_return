import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_safe_return/provider/setting/inquiry/inquiry_post_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

class InquiryPost extends ConsumerStatefulWidget {
  const InquiryPost({super.key});

  @override
  ConsumerState<InquiryPost> createState() => _InquiryPostState();
}

class _InquiryPostState extends ConsumerState<InquiryPost> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final List<String> claimTypes = [
    '기타',
    '회원 정보',
    '연락처',
    'SMS',
    '귀가 로그',
    '지도',
    '버그 신고',
    '보안 문의',
  ];
  String selectedClaim = '기타';
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                    '문의하기',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: '제목',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '클레임 유형',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(selectedClaim),
                                    Icon(isExpanded
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: claimTypes.map((type) {
                                    return ListTile(
                                      title: Text(type),
                                      onTap: () {
                                        setState(() {
                                          selectedClaim = type;
                                          isExpanded = false;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: TextField(
                          controller: contentController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            labelText: '문의 내용',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final content = contentController.text.trim();

                            if (title.isEmpty || content.isEmpty) {
                              showPopup(context, '제목과 내용을 모두 입력해주세요.');
                              return;
                            }

                            final prefs = await SharedPreferences.getInstance();
                            final memberNumberString = prefs.getString('memberNumber');
                            final memberNumber = int.tryParse(memberNumberString ?? '');

                            if (memberNumber == null) {
                              showPopup(context, '로그인 정보가 없습니다. 다시 로그인 해주세요.');
                              return;
                            }

                            ref.read(postInquiryProvider).postInquiry(
                                  context: context,
                                  title: title,
                                  category: selectedClaim,
                                  content: content,
                                  memberNumber: memberNumber,
                                  onSuccess: () {
                                    titleController.clear();
                                    contentController.clear();
                                  },
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: signatureColor,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('등록'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
