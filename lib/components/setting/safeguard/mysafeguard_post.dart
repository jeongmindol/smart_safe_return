import 'package:flutter/material.dart';

class MySafeguardPost extends StatefulWidget {
  final Function(String, String) onAddGuardian;

  const MySafeguardPost({super.key, required this.onAddGuardian});

  @override
  State<MySafeguardPost> createState() => _MySafeguardPostState();
}

class _MySafeguardPostState extends State<MySafeguardPost> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // 💙 signatureColor 추가
  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // ✅ 전체 스크롤 가능하게!
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              '안전지킴이 등록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: '이름'),
                        ),
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(labelText: '연락처'),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();

                  if (name.isNotEmpty && phone.isNotEmpty) {
                    widget.onAddGuardian(name, phone);
                    nameController.clear();
                    phoneController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('안전지킴이 등록 완료')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: signatureColor, // 💙 하늘색!
                  foregroundColor: Colors.black,
                ),
                child: const Text('등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
