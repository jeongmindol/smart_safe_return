import 'package:flutter/material.dart';
import 'package:smart_safe_return/provider/setting/user/id_search_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart'; // ✅ 팝업 import

class IdSearchPage extends StatefulWidget {
  const IdSearchPage({super.key});

  @override
  State<IdSearchPage> createState() => _IdSearchPageState();
}

class _IdSearchPageState extends State<IdSearchPage> {
  final provider = IdSearchProvider();
  static const signatureColor = Color.fromARGB(255, 102, 247, 255);

  @override
  void initState() {
    super.initState();
    provider.onTimerTick = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    provider.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이디 찾기')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: provider.phoneController,
                    decoration: const InputDecoration(
                      hintText: '휴대전화 (-없이)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await provider.requestIdVerification(context); // ✅ context 전달
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signatureColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("인증 요청"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (provider.isCodeInputVisible)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: provider.codeController,
                          decoration: InputDecoration(
                            hintText: '인증 코드 입력',
                            border: const OutlineInputBorder(),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  '${provider.remainingSeconds ~/ 60}:${(provider.remainingSeconds % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final id = await provider.findId();
                          setState(() {});
                          provider.codeController.clear();
                          if (id == null) {
                            showInvalidCodePopup(context); // ✅ 팝업으로 변경됨
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("확인"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: (provider.canResend &&
                                provider.resendCount < 3)
                            ? () async {
                                await provider.requestIdVerification(context); // ✅ context 전달
                                setState(() {});
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (provider.canResend &&
                                  provider.resendCount < 3)
                              ? Colors.orange
                              : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("재전송"),
                      ),
                    ],
                  ),
                  if (provider.foundId != null) ...[
                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            '회원님의 아이디는',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '" ${provider.foundId} " 입니다.',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
