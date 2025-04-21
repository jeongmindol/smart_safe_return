// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:smart_safe_return/api/user/emergency_service.dart'; // 연락처 모델
// import 'package:smart_safe_return/services/location_service.dart';
// import 'package:smart_safe_return/services/send_message_log.dart';

// class CountdownDisplay extends StatefulWidget {
//   final Duration initialDuration;
//   final int safeRouteId;
//   final String message;
//   final List<String> phoneList;

//   const CountdownDisplay({
//     super.key,
//     required this.initialDuration,
//     required this.safeRouteId,
//     required this.message,
//     required this.phoneList,
//   });

//   @override
//   State<CountdownDisplay> createState() => _CountdownDisplayState();
// }

// class _CountdownDisplayState extends State<CountdownDisplay> {
//   late Duration _remaining;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _remaining = widget.initialDuration;
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       if (_remaining.inSeconds <= 1) {
//         timer.cancel();
//         await _handleTimeout();
//       } else {
//         setState(() {
//           _remaining -= const Duration(seconds: 1);
//         });
//       }
//     });
//   }

//   Future<void> _handleTimeout() async {
//     print("⏰ 타이머 종료! 메시지 전송 시작");

//     await sendMessageLog(
//       safeRouteId: widget.safeRouteId,
//       message: widget.message,
//       phoneList: widget.phoneList,
//     );

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("🚨 SOS 메시지를 전송했습니다.")),
//       );
//     }
//   }

//   String _format(Duration duration) {
//     final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$minutes : $seconds";
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       "남은 시간: ${_format(_remaining)}",
//       style: const TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: Colors.redAccent,
//       ),
//       textAlign: TextAlign.center,
//     );
//   }
// }
