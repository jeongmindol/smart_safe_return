import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:smart_safe_return/components/navbar/bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 초기화 필요
  await dotenv.load(fileName: 'assets/config/.env');

  // 네이버 맵 SDK 초기화
  await _initialize(); // _initialize 함수 호출

  runApp(const ProviderScope(child: MyApp()));
}

// 지도 초기화하기
Future<void> _initialize() async {
  String naverClientId =
      dotenv.env['NAVER_CLIENT_ID'] ?? ''; // .env에서 클라이언트 아이디 가져오기
  // print(naverClientId);

  if (naverClientId.isEmpty) {
    throw Exception("네이버 클라이언트 아이디가 .env 파일에 설정되지 않았습니다.");
  }

  await NaverMapSdk.instance.initialize(
    clientId: naverClientId, // 클라이언트 ID 설정
    onAuthFailed: (e) => print("네이버 맵 인증 실패: $e"),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YoungFlix',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        secondaryHeaderColor: Colors.white,
      ),
      home: const Scaffold(
        body: Bottom(), // Bottom 컴포넌트로 모든 UI를 이동
      ),
    );
  }
}


// 노일 main
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:smart_safe_return/components/navbar/bottom_bar.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: 'assets/config/.env');


//   runApp(const ProviderScope(child: MyApp()));
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});


//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Smart Safe Return',
//       theme: ThemeData(
//         brightness: Brightness.light,
//         primaryColor: Colors.black,
//         secondaryHeaderColor: Colors.white,
//       ),
//       home: const Scaffold(
//         // ✅ 여기서 Material 구조 안에 넣어줌!
//         body: Bottom(),
//       ),
//     );
//   }
// }

