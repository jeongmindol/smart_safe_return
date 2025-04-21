// lib/components/setting/sossms/mysossms_post.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';
import 'package:smart_safe_return/provider/setting/sossms/mysossms_post_provider.dart';

class MySosSmsPost extends ConsumerWidget {
  final TextEditingController messageController;
  final int memberNumber;
  final TabController tabController; // ✅ 탭 컨트롤러 추가

  MySosSmsPost({
    super.key,
    required this.messageController,
    required this.memberNumber,
    required this.tabController, // ✅ 생성자에 추가
  });

  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: TextField(
              controller: messageController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'SOS 메시지 내용\n(출발지, 목적지, 예상 도착 시간을 제외한 SOS메세지에 필요한 내용을 200자 내외로 작성해주세요.)',
                hintMaxLines: 3,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final content = messageController.text.trim();
                if (content.isNotEmpty) {
                  ref.read(postSosMessageProvider).postSosMessage(
                        context: context,
                        memberNumber: memberNumber,
                        content: content,
                        onSuccess: () {
                          messageController.clear();         // ✅ 입력창 초기화
                          tabController.index = 0;           // ✅ 마이 메시지 탭으로 이동
                        },
                         onDuplicate: () {
        messageController.clear();       // ✅ 중복 시 초기화
      },
                      );
                } else {
                  showPopup(context, '내용을 입력해주세요.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: signatureColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '메시지 저장',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
