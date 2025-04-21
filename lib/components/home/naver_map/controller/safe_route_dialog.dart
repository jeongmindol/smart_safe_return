import 'package:flutter/material.dart';
import 'package:smart_safe_return/api/user/emergency_service.dart';

Future<void> showSafeRouteDialog({
  required BuildContext context,
  required void Function(
    List<EmergencyContact> selectedContacts,
    String message,
  ) onConfirm,
}) async {
  final contacts = await fetchEmergencyContact();
  final sosMessage = await fetchSosMessage(); // 단일 메시지

  if (contacts.isEmpty || sosMessage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ 비상 연락처 또는 SOS 메시지를 불러오지 못했습니다.')),
    );
    return;
  }

  List<EmergencyContact> selectedContacts = [];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('📍 안전 귀가 설정'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ 비상 연락처를 선택하세요',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: contacts.map((contact) {
                      final isSelected = selectedContacts.contains(contact);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedContacts.remove(contact);
                            } else {
                              selectedContacts.add(contact);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? Colors.green : Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          child: Text('${contact.name} (${contact.phone})'),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('🆘 전송 예정 메시지',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sosMessage.content,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('취소'),
              ),
              ElevatedButton(
                onPressed: selectedContacts.isNotEmpty
                    ? () {
                        Navigator.of(context).pop();
                        print("✅ 선택된 연락처 수: ${selectedContacts.length}");
                        print("✅ 사용할 메시지: ${sosMessage.content}");
                        onConfirm(selectedContacts, sosMessage.content);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text("안전 귀가 시작"),
              ),
            ],
          );
        },
      );
    },
  );
}
