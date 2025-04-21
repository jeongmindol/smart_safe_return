import 'package:flutter/material.dart';

class TrackingControls extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  const TrackingControls({
    super.key,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("취소하기"),
        ),
        ElevatedButton(
          onPressed: isPaused ? onResume : onPause,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPaused ? Colors.orange : Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(isPaused ? "재시작" : "정지"),
        ),
      ],
    );
  }
}
