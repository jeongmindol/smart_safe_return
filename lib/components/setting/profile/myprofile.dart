import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/provider/setting/profile/myprofile_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';
import 'package:smart_safe_return/components/setting/user/user.dart';
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends ConsumerStatefulWidget {
  const MyProfile({super.key});

  @override
  ConsumerState<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends ConsumerState<MyProfile> {
  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);
  final Map<String, bool> isEditing = {
    '아이디': false,
    '비밀번호': false,
    '연락처': false,
  };
  final Map<String, TextEditingController> controllers = {
    '아이디': TextEditingController(),
    '비밀번호': TextEditingController(),
    '연락처': TextEditingController(),
    '회원탈퇴비번': TextEditingController(),
  };
  bool showWithdrawField = false;
  bool showFinalWithdrawConfirm = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 246, 252),
      body: SafeArea(
        child: profileAsync.when(
          data: (memberData) {
            controllers['아이디']!.text = memberData.id;
            controllers['연락처']!.text = memberData.phone;
            controllers['비밀번호']!.text = '';

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    color: signatureColor,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          '내 정보 수정',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileItem(context, ref, '아이디', memberData.id),
                        const SizedBox(height: 20),
                        buildProfileItem(context, ref, '비밀번호', '********'),
                        const SizedBox(height: 20),
                        buildProfileItem(context, ref, '연락처', formatPhone(memberData.phone)),
                        const SizedBox(height: 40),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() => showWithdrawField = !showWithdrawField);
                            },
                            child: const Text(
                              '회원 탈퇴',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        if (showWithdrawField)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('비밀번호 확인', style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: controllers['회원탈퇴비번'],
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        hintText: '비밀번호 입력',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final enteredPw = controllers['회원탈퇴비번']!.text;
                                      final isMatch = await checkPasswordMatch(
                                        ref: ref,
                                        inputId: memberData.id,
                                        inputPassword: enteredPw,
                                      );

                                      if (!isMatch) {
                                        showPopup(context, '비밀번호가 일치하지 않아요\n다시 입력해주세요');
                                      } else {
                                        setState(() => showFinalWithdrawConfirm = true);
                                        showWithdrawConfirmPopup(
                                          context,
                                          () async {
                                            final success = await deleteMyAccount(ref);
                                            if (success) {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.clear();
                                              if (context.mounted) {
                                                Navigator.of(context, rootNavigator: true).pop();
                                                showAccountDeletedPopup(context);
                                              }
                                            } else {
                                              if (context.mounted) {
                                                Navigator.of(context, rootNavigator: true).pop();
                                                showPopup(context, '회원 탈퇴에 실패했습니다');
                                              }
                                            }
                                          },
                                          () {
                                            Navigator.of(context, rootNavigator: true).pop();
                                            setState(() {
                                              showWithdrawField = true;
                                              showFinalWithdrawConfirm = false;
                                              controllers['회원탈퇴비번']?.clear();
                                            });
                                          },
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('확인', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('회원 정보를 불러오는 데 실패했어요\n$error', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileItem(BuildContext context, WidgetRef ref, String title, String value) {
    final isEdit = isEditing[title] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$title: $value',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing[title] = !(isEditing[title] ?? false);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: signatureColor,
                foregroundColor: Colors.black,
              ),
              child: Text(isEdit ? '취소' : '수정'),
            ),
          ],
        ),
        if (isEdit)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllers[title],
                    obscureText: title == '비밀번호',
                    decoration: InputDecoration(
                      hintText: '$title 입력',
                      border: const OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 16),
                    keyboardType: title == '연락처' ? TextInputType.number : TextInputType.text,
                    inputFormatters: title == '연락처'
                        ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)]
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final newValue = controllers[title]!.text.trim();
                    bool success = false;
                    if (title == '아이디') {
                      success = await updateMyProfile(ref: ref);
                    } else if (title == '비밀번호') {
                      success = await updateMyProfile(ref: ref, password: newValue);
                    } else if (title == '연락처') {
                      success = await updateMyProfile(ref: ref, phone: newValue);
                    }
                    if (success) {
                      setState(() => isEditing[title] = false);
                      ref.invalidate(myProfileProvider);
                      showPopup(context, '$title가 수정되었어요!');
                    } else {
                      showPopup(context, '수정에 실패했어요.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('저장', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String formatPhone(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}-${phone.substring(3, 7)}-${phone.substring(7)}';
    }
    return phone;
  }
}