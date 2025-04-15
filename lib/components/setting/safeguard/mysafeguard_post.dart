import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_safe_return/provider/setting/safeguard/mysafeguard_post_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart'; // ✅ 팝업 불러오기

class MySafeguardPost extends StatefulWidget {
  final Function(String, String) onAddGuardian;

  const MySafeguardPost({super.key, required this.onAddGuardian});

  @override
  State<MySafeguardPost> createState() => _MySafeguardPostState();
}

class _MySafeguardPostState extends State<MySafeguardPost> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);

  int? memberNumber;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMemberNumber();
  }

  Future<void> _loadMemberNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedMemberNumber = prefs.getString('memberNumber');
    if (loadedMemberNumber != null) {
      setState(() {
        memberNumber = int.tryParse(loadedMemberNumber);
      });
    }
  }

  Future<void> handleRegister() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty || memberNumber == null) {
      showPopup(context, '이름, 연락처를 입력하거나 로그인 정보를 확인해주세요');
      return;
    }

    setState(() => isLoading = true);

    final provider = MySafeguardPostProvider();
    final success = await provider.registerGuardian(
      memberNumber: memberNumber!,
      name: name,
      phone: phone,
    );

    setState(() => isLoading = false);

    if (success) {
      widget.onAddGuardian(name, phone);
      nameController.clear();
      phoneController.clear();
      showPopup(context, '안전지킴이 등록이 완료되었습니다.');
    } else {
      showPopup(context, '이미 등록된 안전지킴이입니다.\n다시 확인해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                onPressed: isLoading ? null : handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: signatureColor,
                  foregroundColor: Colors.black,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
