import 'package:flutter/material.dart';

class MySosSmsPost extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController messageController;
  final VoidCallback onSave;

  const MySosSmsPost({
    super.key,
    required this.titleController,
    required this.messageController,
    required this.onSave,
  });

  // 💙 signatureColor 정의
  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: SingleChildScrollView(
        // SingleChildScrollView로 감싸서 스크롤 가능하게 변경
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: TextField(
                controller: messageController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText:
                      'SOS 메시지 내용\n(출발지, 목적지, 예상 도착 시간을 제외한 SOS메세지에 필요한 내용을 작성해주세요.)',
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
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: signatureColor, // 💙 하늘색 적용!
                  foregroundColor: Colors.black, // 글씨는 검정색
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
      ),
    );
  }
}
