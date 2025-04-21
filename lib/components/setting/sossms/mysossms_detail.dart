import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_safe_return/provider/setting/sossms/mysossms_detail_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

final memberNumberProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final number = prefs.getString('memberNumber');
  if (number == null) throw Exception('memberNumber가 없습니다!');
  return int.parse(number);
});

class MySosSmsDetail extends ConsumerStatefulWidget {
  const MySosSmsDetail({super.key});

  @override
  ConsumerState<MySosSmsDetail> createState() => _MySosSmsDetailState();
}

class _MySosSmsDetailState extends ConsumerState<MySosSmsDetail> {
  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);
  bool isEditing = false;
  final TextEditingController editController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      final memberNumber = prefs.getString('memberNumber');
      if (memberNumber != null) {
        final parsed = int.parse(memberNumber);
        ref.invalidate(sosMessageProvider(parsed));
        ref.invalidate(sosMessageIdProvider(parsed));
      }
    });
  }

  Future<void> submitEdit(int memberNumber) async {
    try {
      final messageId = await ref.read(sosMessageIdProvider(memberNumber).future);

      final result = await ref.read(
        updateSosMessageProvider((id: messageId, content: editController.text)).future,
      );

      if (!mounted) return;

      if (result) {
        setState(() => isEditing = false);
        ref.invalidate(sosMessageProvider(memberNumber));
        showPopup(context, "메시지가 성공적으로 수정되었어요.");
      } else {
        showPopup(context, "메시지 수정에 실패했어요. 다시 시도해주세요.");
      }
    } catch (e) {
      if (!mounted) return;
      showPopup(context, "오류가 발생했어요:\n$e");
    }
  }

  Future<void> confirmDelete(int memberNumber) async {
    showDeleteConfirmPopup(
      context,
      onConfirm: () async {
        try {
          final messageId = await ref.read(sosMessageIdProvider(memberNumber).future);

          final deleteSosMessage = ref.read(deleteSosMessageProvider);
          final result = await deleteSosMessage(messageId);

          if (!mounted) return;

          Navigator.of(context, rootNavigator: true).pop();

          if (result) {
            setState(() {
              editController.clear();
              isEditing = false;
            });
            ref.invalidate(sosMessageProvider(memberNumber));
            showPopup(context, "메시지가 삭제되었어요.");
          } else {
            showPopup(context, "메시지 삭제에 실패했어요. 다시 시도해주세요.");
          }
        } catch (e) {
          if (!mounted) return;
          Navigator.pop(context);
          showPopup(context, "삭제 중 오류 발생:\n$e");
        }
      },
      onCancel: () {
        if (!mounted) return;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncMemberNumber = ref.watch(memberNumberProvider);

    return asyncMemberNumber.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const SizedBox.shrink(),
      data: (memberNumber) {
        final asyncMessage = ref.watch(sosMessageProvider(memberNumber));

        return asyncMessage.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => buildEmptyMessage(memberNumber),
          data: (detailRaw) {
            if (!isEditing) editController.text = detailRaw;

            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      '마이 메세지',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    if (isEditing)
                      TextField(
                        controller: editController,
                        maxLines: 5,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          hintText: '메시지를 입력해주세요',
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      Text(
                        editController.text.isNotEmpty ? detailRaw : '',
                        style: const TextStyle(fontSize: 20, color: Colors.black87, height: 2.5),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() => isEditing = !isEditing);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[200],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(isEditing ? '취소' : '수정', style: const TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 20),
                        if (isEditing)
                          ElevatedButton(
                            onPressed: () => submitEdit(memberNumber),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: signatureColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('메세지 저장', style: TextStyle(fontSize: 16)),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => confirmDelete(memberNumber),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[200],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('삭제', style: TextStyle(fontSize: 16)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildEmptyMessage(int memberNumber) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              '마이 메세지',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const SizedBox(height: 120),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() => isEditing = !isEditing);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isEditing ? '취소' : '수정', style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => confirmDelete(memberNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signatureColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('삭제', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
