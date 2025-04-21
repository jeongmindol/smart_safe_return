import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_safe_return/provider/setting/safeguard/mysafeguard_list_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

class MySafeguardList extends StatefulWidget {
  const MySafeguardList({Key? key}) : super(key: key);

  @override
  State<MySafeguardList> createState() => MySafeguardListState();
}

class MySafeguardListState extends State<MySafeguardList> {
  int? expandedIndex;
  int? editingIndex;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);
  List<Map<String, String>> guardians = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshGuardians();
  }

  Future<void> refreshGuardians() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final memberStr = prefs.getString('memberNumber');
    final memberNumber = int.tryParse(memberStr ?? '');
    if (memberNumber == null) return;

    try {
      final provider = MySafeguardListProvider();
      final fetched = await provider.fetchGuardians(memberNumber);
      setState(() {
        guardians = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String formatPhoneNumber(String raw) {
    if (raw.length == 11) {
      return '${raw.substring(0, 3)}-${raw.substring(3, 7)}-${raw.substring(7)}';
    } else if (raw.length == 10) {
      return '${raw.substring(0, 3)}-${raw.substring(3, 6)}-${raw.substring(6)}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guardians.length,
      itemBuilder: (context, index) {
        final guardian = guardians[index];
        final isExpanded = expandedIndex == index;

        return Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  expandedIndex = isExpanded ? null : index;
                });
              },
              child: Container(
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        guardian['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: signatureColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text('선택'),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: 12.0, left: 60.0, right: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                formatPhoneNumber(guardian['phone']!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    editingIndex = index;
                                    nameController.text = guardian['name']!;
                                    phoneController.text = guardian['phone']!;
                                  });
                                },
                                child: const Text(
                                  '수정',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () {
                                  showDeleteConfirmPopup(
                                    context,
                                    onConfirm: () async {
                                      Navigator.of(context, rootNavigator: true).pop();
                                      try {
                                        final provider = MySafeguardListProvider();
                                        final id = guardian['id'];
                                        await provider.deleteGuardian(int.parse(id!));
                                        showPopup(context, '삭제가 완료되었습니다.');
                                        refreshGuardians();
                                      } catch (e) {
                                        showPopup(context, '삭제 중 오류가 발생했습니다.');
                                      }
                                    },
                                    onCancel: () {
                                      Navigator.of(context, rootNavigator: true).pop();
                                      showPopup(context, '삭제가 취소되었습니다.');
                                    },
                                  );
                                },
                                child: const Text(
                                  '삭제',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (editingIndex == index)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                              labelText: '이름 수정'),
                                        ),
                                        TextField(
                                          controller: phoneController,
                                          decoration: const InputDecoration(
                                              labelText: '연락처 수정'),
                                          keyboardType: TextInputType.phone,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        final provider = MySafeguardListProvider();
                                        final id = guardian['id'];
                                        await provider.updateGuardian(
                                          int.parse(id!),
                                          nameController.text,
                                          phoneController.text,
                                        );
                                        showGuardianUpdateSuccessPopup(context);
                                        setState(() {
                                          editingIndex = null;
                                        });
                                        refreshGuardians();
                                      } catch (e) {
                                        showPopup(context, '❌ 수정 실패: $e');
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      '확인',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}