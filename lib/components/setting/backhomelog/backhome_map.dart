import 'package:flutter/material.dart';

class BackHomeMap extends StatelessWidget {
  final dynamic routePath; // ✅ routePath 받기

  const BackHomeMap({super.key, required this.routePath});

  @override
  Widget build(BuildContext context) {
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    // ✅ 콘솔에만 출력
    print("🗺️ 전달받은 경로 routePath: $routePath");

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
                    '안전 귀가 지도',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  '🗺️ 지도 준비 중...',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
